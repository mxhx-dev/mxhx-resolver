/*
	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.
 */

package mxhx.resolver.rtti;

import haxe.rtti.CType;
import haxe.rtti.XmlParser;
import mxhx.internal.resolver.MXHXAbstractSymbol;
import mxhx.internal.resolver.MXHXClassSymbol;
import mxhx.internal.resolver.MXHXEnumFieldSymbol;
import mxhx.internal.resolver.MXHXEnumSymbol;
import mxhx.internal.resolver.MXHXFieldSymbol;
import mxhx.internal.resolver.MXHXInterfaceSymbol;
import mxhx.resolver.IMXHXAbstractSymbol;
import mxhx.resolver.IMXHXClassSymbol;
import mxhx.resolver.IMXHXEnumFieldSymbol;
import mxhx.resolver.IMXHXEnumSymbol;
import mxhx.resolver.IMXHXEventSymbol;
import mxhx.resolver.IMXHXFieldSymbol;
import mxhx.resolver.IMXHXInterfaceSymbol;
import mxhx.resolver.IMXHXResolver;
import mxhx.resolver.IMXHXSymbol;
import mxhx.resolver.IMXHXTypeSymbol;
import mxhx.resolver.MXHXResolvers;
import mxhx.resolver.MXHXSymbolTools;

/**

	An MXHX resolver that uses the [Haxe Runtime Type Information](https://haxe.org/manual/cr-rtti.html)
	to resolve symbols.
**/
class MXHXRttiResolver implements IMXHXResolver {
	private static final TYPE_ARRAY = "Array";
	private static final ATTRIBUTE_TYPE = "type";
	private static final META_ENUM = ":enum";
	private static final META_DEFAULT_XML_PROPERTY = "defaultXmlProperty";

	public function new() {
		manifests = MXHXResolvers.emitMappings();
	}

	private var manifests:Map<String, Map<String, String>> /* Map<Uri<TagName, Qname>> */ = [];
	private var qnameToMXHXTypeSymbolLookup:Map<String, IMXHXTypeSymbol> = [];

	public function registerManifest(uri:String, mappings:Map<String, String>):Void {
		manifests.set(uri, mappings);
	}

	public function resolveTag(tagData:IMXHXTagData):IMXHXSymbol {
		if (tagData == null) {
			return null;
		}
		if (!hasValidPrefix(tagData)) {
			return null;
		}
		var resolvedProperty = resolveTagAsPropertySymbol(tagData);
		if (resolvedProperty != null) {
			return resolvedProperty;
		}
		var resolvedEvent = resolveTagAsEventSymbol(tagData);
		if (resolvedEvent != null) {
			return resolvedEvent;
		}
		return resolveTagAsTypeSymbol(tagData);
	}

	public function resolveAttribute(attributeData:IMXHXTagAttributeData):IMXHXSymbol {
		if (attributeData == null) {
			return null;
		}
		var tagData:IMXHXTagData = attributeData.parentTag;
		var tagSymbol = resolveTag(tagData);
		if (tagSymbol == null || !(tagSymbol is IMXHXClassSymbol)) {
			return null;
		}
		var classSymbol:IMXHXClassSymbol = cast tagSymbol;
		var field = MXHXSymbolTools.resolveFieldByName(classSymbol, attributeData.shortName);
		if (field != null) {
			return field;
		}
		var event = MXHXSymbolTools.resolveEventByName(classSymbol, attributeData.shortName);
		if (event != null) {
			return event;
		}
		return null;
	}

	public function resolveTagField(tagData:IMXHXTagData, fieldName:String):IMXHXFieldSymbol {
		var tagSymbol = resolveTag(tagData);
		if (tagSymbol == null || !(tagSymbol is IMXHXClassSymbol)) {
			return null;
		}
		var classSymbol:IMXHXClassSymbol = cast tagSymbol;
		return MXHXSymbolTools.resolveFieldByName(classSymbol, fieldName);
	}

	public function resolveQname(qname:String):IMXHXTypeSymbol {
		if (qname == null) {
			return null;
		}
		var resolved = qnameToMXHXTypeSymbolLookup.get(qname);
		if (resolved != null) {
			return resolved;
		}
		if (StringTools.startsWith(qname, "StdTypes.")) {
			qname = qname.substr(9);
		}
		var nameToResolve = qname;
		var paramsStart = qname.indexOf("<");
		var params:Array<IMXHXTypeSymbol> = [];
		if (paramsStart != -1) {
			nameToResolve = qname.substr(0, paramsStart);
			params = qnameToParams(qname, paramsStart);
		}
		if (nameToResolve == "haxe.Constraints.Function") {
			nameToResolve = "haxe.Function";
		}
		// these built-in abstracts don't resolve consistently across targets at runtime
		switch (nameToResolve) {
			case "Any" | "Bool" | "Class" | "Dynamic" | "Enum" | "EnumValue" | "Float" | "Int" | "Null" | "UInt" | "haxe.Function":
				return createMXHXAbstractSymbolForBuiltin(nameToResolve, params);
			default:
		}
		var resolvedEnum = Type.resolveEnum(nameToResolve);
		if ((resolvedEnum is Enum)) {
			var enumTypeTree:TypeTree;
			try {
				enumTypeTree = getTypeTree(resolvedEnum);
			} catch (e:Dynamic) {
				return createMXHXEnumSymbolForEnum(resolvedEnum, params);
			}
			switch (enumTypeTree) {
				case TEnumdecl(enumdef):
					return createMXHXEnumSymbolForEnumdef(enumdef, params);
				default:
					return createMXHXEnumSymbolForEnum(resolvedEnum, params);
			}
		}
		var resolvedClass = Type.resolveClass(nameToResolve);
		if (resolvedClass == null) {
			return null;
		}

		var classTypeTree:TypeTree;
		try {
			classTypeTree = getTypeTree(resolvedClass);
		} catch (e:Dynamic) {
			return createMXHXClassSymbolForClass(resolvedClass, params);
		}
		switch (classTypeTree) {
			case TClassdecl(classdef):
				if (classdef.isInterface) {
					return createMXHXInterfaceSymbolForClassdef(classdef, params);
				}
				return createMXHXClassSymbolForClassdef(classdef, params);
			case TEnumdecl(enumdef):
				return createMXHXEnumSymbolForEnumdef(enumdef, params);
			case TAbstractdecl(abstractdef):
				return createMXHXAbstractSymbolForAbstractdef(abstractdef, params);
			default:
				return createMXHXClassSymbolForClass(resolvedClass, params);
		}
	}

	private static function getTypeTree<T>(c:Any):TypeTree {
		var rtti = Reflect.field(c, "__rtti");
		if (rtti == null) {
			if ((c is Class)) {
				throw 'Class ${Type.getClassName(c)} has no RTTI information, consider adding @:rtti';
			} else if ((c is Enum)) {
				throw 'Enum ${Type.getEnumName(c)} has no RTTI information, consider adding @:rtti';
			} else {
				throw 'Value ${c} has no RTTI information, consider adding @:rtti';
			}
		}
		var x = Xml.parse(rtti).firstElement();
		return new haxe.rtti.XmlParser().processElement(x);
	}

	public function getTagNamesForQname(qnameToFind:String):Map<String, String> {
		var result:Map<String, String> = [];
		for (uri => mappings in manifests) {
			for (tagName => qname in mappings) {
				if (qname == qnameToFind) {
					result.set(uri, tagName);
				}
			}
		}
		return result;
	}

	private function classToQname(resolvedClass:Class<Dynamic>, params:Array<IMXHXTypeSymbol> = null):String {
		var qname = Type.getClassName(resolvedClass);
		if (qname == null) {
			return null;
		}
		var dotIndex = qname.lastIndexOf(".");
		var name = qname;
		var pack:Array<String> = [];
		if (dotIndex != -1) {
			name = qname.substr(dotIndex + 1);
			var packString = qname.substr(0, dotIndex);
			pack = packString.split(".");
		}
		var moduleName = name;
		if (pack.length > 0) {
			moduleName = pack.join(".") + "." + name;
		}
		return MXHXResolverTools.definitionToQname(name, pack, moduleName, params != null ? params.map(param -> param != null ? param.qname : null) : []);
	}

	private function createMXHXAbstractSymbolForBuiltin(qname:String, params:Array<IMXHXTypeSymbol>):IMXHXAbstractSymbol {
		var dotIndex = qname.lastIndexOf(".");
		var name = qname;
		var pack:Array<String> = [];
		if (dotIndex != -1) {
			name = qname.substr(dotIndex + 1);
			var packString = qname.substr(0, dotIndex);
			pack = packString.split(".");
		}
		var moduleName = name;
		if (pack.length > 0) {
			moduleName = pack.join(".") + "." + name;
		}
		qname = MXHXResolverTools.definitionToQname(name, pack, moduleName, params.map(param -> param != null ? param.qname : null));
		var result = new MXHXAbstractSymbol(name, [], params);
		result.qname = qname;
		return result;
	}

	private function createMXHXClassSymbolForClass(resolvedClass:Class<Dynamic>, params:Array<IMXHXTypeSymbol>):IMXHXClassSymbol {
		var qname = Type.getClassName(resolvedClass);
		if (qname == null) {
			return null;
		}
		var dotIndex = qname.lastIndexOf(".");
		var name = qname;
		var pack:Array<String> = [];
		if (dotIndex != -1) {
			name = qname.substr(dotIndex + 1);
			var packString = qname.substr(0, dotIndex);
			pack = packString.split(".");
		}
		var moduleName = name;
		if (pack.length > 0) {
			moduleName = pack.join(".") + "." + name;
		}
		qname = MXHXResolverTools.definitionToQname(name, pack, moduleName, params.map(param -> param != null ? param.qname : null));
		var result = new MXHXClassSymbol(name, pack, params);
		result.qname = qname;
		var resolvedSuperClass = Type.getSuperClass(resolvedClass);
		if (resolvedSuperClass != null) {
			var superClassQname = classToQname(resolvedSuperClass);
			var classType = resolveQname(superClassQname);
			if (!(classType is IMXHXInterfaceSymbol)) {
				throw 'Expected class: ${classType.qname}. Is it missing @:rtti metadata?';
			}
			result.superClass = cast(classType, IMXHXClassSymbol);
		}
		var fields:Array<IMXHXFieldSymbol> = [];
		// fields = fields.concat(Type.getInstanceFields(resolvedClass).map(field -> createMXHXFieldSymbolForTypeField(field, false)));
		// fields = fields.concat(Type.getClassFields(resolvedClass).map(field -> createMXHXFieldSymbolForTypeField(field, true)));
		result.fields = fields;

		return result;
	}

	private function createMXHXClassSymbolForClassdef(classdef:Classdef, params:Array<IMXHXTypeSymbol>):IMXHXClassSymbol {
		var name = classdef.path;
		var dotIndex = name.lastIndexOf(".");
		var pack:Array<String> = [];
		if (dotIndex != -1) {
			var packString = name.substr(0, dotIndex);
			pack = packString.split(".");
			name = name.substr(dotIndex + 1);
		}
		var moduleName = classdef.module;
		if (moduleName == null) {
			moduleName = classdef.path;
		}
		var qname = MXHXResolverTools.definitionToQname(name, pack, moduleName,
			params != null ? params.map(param -> param != null ? param.qname : null) : null);
		var result = new MXHXClassSymbol(name, pack);
		result.qname = qname;
		result.module = moduleName;
		result.doc = classdef.doc;
		result.file = classdef.file;
		// result.offsets = {start: pos.min, end: pos.max};
		result.isPrivate = classdef.isPrivate;
		// fields may reference this type, so make sure that it's available
		// before parsing anything else
		qnameToMXHXTypeSymbolLookup.set(qname, result);

		if (classdef.superClass != null) {
			var classType = resolveQname(classdef.superClass.path);
			if (!(classType is IMXHXClassSymbol)) {
				throw 'Expected class: ${classType.qname}. Is it missing @:rtti metadata?';
			}
			result.superClass = cast(classType, IMXHXClassSymbol);
		}
		var resolvedInterfaces:Array<IMXHXInterfaceSymbol> = [];
		for (currentInterface in classdef.interfaces) {
			var interfaceType = resolveQname(currentInterface.path);
			if (!(interfaceType is IMXHXInterfaceSymbol)) {
				throw 'Expected interface: ${interfaceType.qname}. Is it missing @:rtti metadata?';
			}
			var resolvedInterface = cast(interfaceType, IMXHXInterfaceSymbol);
			resolvedInterfaces.push(resolvedInterface);
		}
		result.interfaces = resolvedInterfaces;
		result.params = params != null ? params : [];
		var fields:Array<IMXHXFieldSymbol> = [];
		fields = fields.concat(classdef.fields.map(field -> createMXHXFieldSymbolForClassField(field, false)));
		fields = fields.concat(classdef.statics.map(field -> createMXHXFieldSymbolForClassField(field, true)));
		result.fields = fields;
		result.meta = classdef.meta != null ? classdef.meta.copy().map(m -> {name: m.name, params: null, pos: null}) : null;
		// result.events = classdef.meta.map(eventMeta -> {
		// 	if (eventMeta.name != ":event") {
		// 		return null;
		// 	}
		// 	if (eventMeta.params.length != 1) {
		// 		return null;
		// 	}
		// 	var eventName = getEventName(eventMeta);
		// 	if (eventName == null) {
		// 		return null;
		// 	}
		// 	var eventTypeQname = getEventType(eventMeta);
		// 	var resolvedType:IMXHXClassSymbol = cast resolveQname(eventTypeQname);
		// 	var result:IMXHXEventSymbol = new MXHXEventSymbol(eventName, resolvedType);
		// 	return result;
		// }).filter(eventSymbol -> eventSymbol != null);
		result.defaultProperty = getDefaultProperty(classdef);
		return result;
	}

	private function createMXHXInterfaceSymbolForClassdef(classdef:Classdef, params:Array<IMXHXTypeSymbol>):IMXHXInterfaceSymbol {
		var name = classdef.path;
		var dotIndex = name.lastIndexOf(".");
		var pack:Array<String> = [];
		if (dotIndex != -1) {
			var packString = name.substr(0, dotIndex);
			pack = packString.split(".");
			name = name.substr(dotIndex + 1);
		}
		var moduleName = classdef.module;
		if (moduleName == null) {
			moduleName = classdef.path;
		}
		var qname = MXHXResolverTools.definitionToQname(name, pack, moduleName,
			params != null ? params.map(param -> param != null ? param.qname : null) : null);
		var result = new MXHXInterfaceSymbol(name, pack);
		result.qname = qname;
		result.module = moduleName;
		result.doc = classdef.doc;
		result.file = classdef.file;
		// result.offsets = {start: pos.min, end: pos.max};
		result.isPrivate = classdef.isPrivate;
		// fields may reference this type, so make sure that it's available
		// before parsing anything else
		qnameToMXHXTypeSymbolLookup.set(qname, result);

		var resolvedInterfaces:Array<IMXHXInterfaceSymbol> = [];
		for (currentInterface in classdef.interfaces) {
			var interfaceType = resolveQname(currentInterface.path);
			if (!(interfaceType is IMXHXInterfaceSymbol)) {
				throw 'Expected interface: ${interfaceType.qname}. Is it missing @:rtti metadata?';
			}
			var resolvedInterface = cast(interfaceType, IMXHXInterfaceSymbol);
			resolvedInterfaces.push(resolvedInterface);
		}
		result.interfaces = resolvedInterfaces;
		result.params = params != null ? params : [];
		var fields:Array<IMXHXFieldSymbol> = [];
		fields = fields.concat(classdef.fields.map(field -> createMXHXFieldSymbolForClassField(field, false)));
		fields = fields.concat(classdef.statics.map(field -> createMXHXFieldSymbolForClassField(field, true)));
		result.fields = fields;
		result.meta = classdef.meta != null ? classdef.meta.copy().map(m -> {name: m.name, params: null, pos: null}) : null;
		// result.events = classdef.meta.map(eventMeta -> {
		// 	if (eventMeta.name != ":event") {
		// 		return null;
		// 	}
		// 	if (eventMeta.params.length != 1) {
		// 		return null;
		// 	}
		// 	var eventName = getEventName(eventMeta);
		// 	if (eventName == null) {
		// 		return null;
		// 	}
		// 	var eventTypeQname = getEventType(eventMeta);
		// 	var resolvedType:IMXHXClassSymbol = cast resolveQname(eventTypeQname);
		// 	var result:IMXHXEventSymbol = new MXHXEventSymbol(eventName, resolvedType);
		// 	return result;
		// }).filter(eventSymbol -> eventSymbol != null);
		// result.defaultProperty = getDefaultProperty(classDefinition);
		return result;
	}

	private function createMXHXEnumSymbolForEnumdef(enumdef:Enumdef, params:Array<IMXHXTypeSymbol>):IMXHXEnumSymbol {
		var name = enumdef.path;
		var dotIndex = name.lastIndexOf(".");
		var pack:Array<String> = [];
		if (dotIndex != -1) {
			var packString = name.substr(0, dotIndex);
			pack = packString.split(".");
			name = name.substr(dotIndex + 1);
		}
		var moduleName = enumdef.module;
		if (moduleName == null) {
			moduleName = enumdef.path;
		}
		var qname = MXHXResolverTools.definitionToQname(name, pack, moduleName,
			params != null ? params.map(param -> param != null ? param.qname : null) : null);
		var result = new MXHXEnumSymbol(name, pack);
		result.qname = qname;
		result.module = moduleName;
		result.doc = enumdef.doc;
		result.file = enumdef.file;
		// result.offsets = {start: pos.min, end: pos.max};
		result.isPrivate = enumdef.isPrivate;
		// fields may reference this type, so make sure that it's available
		// before parsing anything else
		qnameToMXHXTypeSymbolLookup.set(qname, result);

		result.params = params != null ? params : [];
		var fields:Array<IMXHXEnumFieldSymbol> = [];
		// fields = fields.concat(classdef.fields.map(field -> createMXHXFieldSymbolForClassField(field, false)));
		// fields = fields.concat(classdef.statics.map(field -> createMXHXFieldSymbolForClassField(field, true)));
		result.fields = fields;
		result.meta = enumdef.meta != null ? enumdef.meta.copy().map(m -> {name: m.name, params: null, pos: null}) : null;
		return result;
	}

	private function createMXHXEnumSymbolForEnum(resolvedEnum:Enum<Dynamic>, params:Array<IMXHXTypeSymbol>):IMXHXEnumSymbol {
		var name = resolvedEnum.getName();
		var dotIndex = name.lastIndexOf(".");
		var pack:Array<String> = [];
		if (dotIndex != -1) {
			var packString = name.substr(0, dotIndex);
			pack = packString.split(".");
			name = name.substr(dotIndex + 1);
		}
		var moduleName = name;
		if (pack.length > 0) {
			moduleName = pack.join(".") + "." + moduleName;
		}
		var qname = MXHXResolverTools.definitionToQname(name, pack, moduleName,
			params != null ? params.map(param -> param != null ? param.qname : null) : null);
		var result = new MXHXEnumSymbol(name, pack);
		result.qname = qname;
		result.module = moduleName;
		result.fields = resolvedEnum.getConstructors().map(function(enumConstructorName:String):IMXHXEnumFieldSymbol {
			return new MXHXEnumFieldSymbol(enumConstructorName, result);
		});
		return result;
	}

	private function createMXHXAbstractSymbolForAbstractdef(abstractdef:Abstractdef, params:Array<IMXHXTypeSymbol>):IMXHXAbstractSymbol {
		var name = abstractdef.path;
		var dotIndex = name.lastIndexOf(".");
		var pack:Array<String> = [];
		if (dotIndex != -1) {
			var packString = name.substr(0, dotIndex);
			pack = packString.split(".");
			name = name.substr(dotIndex + 1);
		}
		var moduleName = abstractdef.module;
		if (moduleName == null) {
			moduleName = abstractdef.path;
		}
		var qname = MXHXResolverTools.definitionToQname(name, pack, moduleName,
			params != null ? params.map(param -> param != null ? param.qname : null) : null);
		var result = new MXHXAbstractSymbol(name, pack);
		result.qname = qname;
		result.module = moduleName;
		result.doc = abstractdef.doc;
		result.file = abstractdef.file;
		// result.offsets = {start: pos.min, end: pos.max};
		result.isPrivate = abstractdef.isPrivate;
		// fields may reference this type, so make sure that it's available
		// before parsing anything else
		qnameToMXHXTypeSymbolLookup.set(qname, result);

		result.params = params != null ? params : [];
		result.meta = abstractdef.meta != null ? abstractdef.meta.copy().map(m -> {name: m.name, params: null, pos: null}) : null;
		return result;
	}

	private function cTypeToQname(ctype:CType):String {
		var ctypeName:String = null;
		var ctypeParams:Array<CType> = null;
		switch (ctype) {
			case CClass(name, params):
				ctypeName = name;
				ctypeParams = params;
			case CAbstract(name, params):
				ctypeName = name;
				ctypeParams = params;
			case CEnum(name, params):
				ctypeName = name;
				ctypeParams = params;
			case CTypedef(name, params):
				ctypeName = name;
				ctypeParams = params;
			case CFunction(args, ret):
				return "haxe.Function";
			case CDynamic(t):
				return "Dynamic";
			case CAnonymous(fields):
				return "Dynamic";
			case CUnknown:
				return "Dynamic";
			default:
				return null;
		}
		if (ctypeName != null) {
			var qname = ctypeName;
			if (ctypeParams != null && ctypeParams.length > 0) {
				qname += "<";
				for (i in 0...ctypeParams.length) {
					if (i > 0) {
						qname += ",";
					}
					qname += cTypeToQname(ctypeParams[i]);
				}
				qname += ">";
			}
			return qname;
		}
		return null;
	}

	private function createMXHXFieldSymbolForTypeField(fieldName:String, isStatic:Bool):IMXHXFieldSymbol {
		var result = new MXHXFieldSymbol(fieldName, null, false, true, isStatic);
		return result;
	}

	private function createMXHXFieldSymbolForClassField(field:ClassField, isStatic:Bool):IMXHXFieldSymbol {
		var resolvedType:IMXHXTypeSymbol = null;
		var typeQname = cTypeToQname(field.type);
		if (typeQname != null) {
			resolvedType = resolveQname(typeQname);
			if (resolvedType == null) {
				// type is included in RTTI data, but it is missing at runtime
				// let's assume that it is an abstract
				resolvedType = createMXHXAbstractSymbolForBuiltin(typeQname, []);
			}
		}
		var isMethod = false;
		var isReadable = false;
		var isWritable = false;
		switch (field.get) {
			case RMethod:
				isMethod = true;
			case RNormal:
				isReadable = true;
			default:
		};
		switch (field.set) {
			case RNormal:
				isWritable = true;
			default:
		};
		var isPublic = field.isPublic;
		var isStatic = isStatic;
		var result = new MXHXFieldSymbol(field.name, resolvedType, isMethod, isPublic, isStatic);
		result.isReadable = isReadable;
		result.isWritable = isWritable;
		result.doc = field.doc;
		// result.file = field.file;
		// result.offsets = {start: field.pos.min, end: field.pos.max};
		result.meta = field.meta != null ? field.meta.copy().map(m -> {name: m.name, params: null, pos: null}) : null;
		return result;
	}

	private function qnameToParams(qname:String, paramsIndex:Int):Array<IMXHXTypeSymbol> {
		var params:Array<IMXHXTypeSymbol> = null;
		var paramsString = qname.substring(paramsIndex + 1, qname.length - 1);
		if (paramsString.length > 0) {
			params = [];
			var startIndex = 0;
			var searchIndex = 0;
			var stackSize = 0;
			while (startIndex < paramsString.length) {
				var nextLeftBracketIndex = paramsString.indexOf("<", searchIndex);
				var nextRightBracketIndex = paramsString.indexOf(">", searchIndex);
				var nextCommaIndex = paramsString.indexOf(",", searchIndex);
				if (nextRightBracketIndex != -1
					&& ((nextCommaIndex == -1 && nextLeftBracketIndex == -1)
						|| (nextLeftBracketIndex != -1 && nextRightBracketIndex < nextLeftBracketIndex)
						|| (nextCommaIndex != -1 && nextRightBracketIndex < nextCommaIndex))) {
					stackSize--;
					searchIndex = nextRightBracketIndex + 1;
				} else if (nextLeftBracketIndex != -1
					&& ((nextCommaIndex == -1 && nextLeftBracketIndex == -1)
						|| (nextCommaIndex != -1 && nextLeftBracketIndex < nextCommaIndex)
						|| (nextRightBracketIndex != -1 && nextLeftBracketIndex < nextRightBracketIndex))) {
					stackSize++;
					searchIndex = nextLeftBracketIndex + 1;
				} else if (nextCommaIndex != -1) {
					searchIndex = nextCommaIndex + 1;
					if (stackSize == 0) {
						var qname = paramsString.substring(startIndex, nextCommaIndex);
						params.push(resolveQname(qname));
						startIndex = searchIndex;
					}
				} else {
					var qname = paramsString.substring(startIndex);
					params.push(resolveQname(qname));
					searchIndex = paramsString.length;
					startIndex = searchIndex;
				}
			}
		}
		return params;
	}

	private function resolveParentTag(tagData:IMXHXTagData):IMXHXSymbol {
		var parentTag = tagData.parentTag;
		if (parentTag == null) {
			return null;
		}
		if (parentTag.prefix != tagData.prefix) {
			return null;
		}
		var resolvedParent = resolveTag(parentTag);
		if (resolvedParent != null) {
			return resolvedParent;
		}
		return null;
	}

	private function hasValidPrefix(tag:IMXHXTagData):Bool {
		var prefixMap = tag.compositePrefixMap;
		if (prefixMap == null) {
			return false;
		}
		return prefixMap.containsPrefix(tag.prefix) && prefixMap.containsUri(tag.uri);
	}

	private function resolveTagAsPropertySymbol(tagData:IMXHXTagData):IMXHXFieldSymbol {
		var parentSymbol = resolveParentTag(tagData);
		if (parentSymbol == null || !(parentSymbol is IMXHXClassSymbol)) {
			return null;
		}
		var classSymbol:IMXHXClassSymbol = cast parentSymbol;
		return MXHXSymbolTools.resolveFieldByName(classSymbol, tagData.shortName);
	}

	private function resolveTagAsEventSymbol(tagData:IMXHXTagData):IMXHXEventSymbol {
		var parentSymbol = resolveParentTag(tagData);
		if (parentSymbol == null || !(parentSymbol is IMXHXClassSymbol)) {
			return null;
		}
		var classSymbol:IMXHXClassSymbol = cast parentSymbol;
		return MXHXSymbolTools.resolveEventByName(classSymbol, tagData.shortName);
	}

	private function resolveTagAsTypeSymbol(tagData:IMXHXTagData):IMXHXSymbol {
		var prefix = tagData.prefix;
		var uri = tagData.uri;
		var localName = tagData.shortName;

		if (uri != null && manifests.exists(uri)) {
			var mappings = manifests.get(uri);
			if (mappings.exists(localName)) {
				var qname = mappings.get(localName);
				if (localName == TYPE_ARRAY) {
					var typeAttr = tagData.getAttributeData(ATTRIBUTE_TYPE);
					if (typeAttr != null) {
						var itemType:IMXHXTypeSymbol = resolveQname(typeAttr.rawValue);
						if (tagData.stateName != null) {
							return null;
						}
						var qname = MXHXResolverTools.definitionToQname(TYPE_ARRAY, [], localName, [itemType.qname]);
						return resolveQname(qname);
					}
				}
				var type = resolveQname(qname);
				if (type != null) {
					if ((type is IMXHXEnumSymbol)) {
						var enumSymbol:IMXHXEnumSymbol = cast type;
						if (tagData.stateName == null) {
							return type;
						}
						return Lambda.find(enumSymbol.fields, field -> field.name == tagData.stateName);
					} else {
						if (tagData.stateName != null) {
							return null;
						}
						return type;
					}
				}
			}
		}
		if (tagData.stateName != null) {
			return null;
		}

		if (uri != "*" && !StringTools.endsWith(uri, ".*")) {
			return null;
		}
		var qname = uri.substr(0, uri.length - 1) + localName;
		var qnameType = resolveQname(qname);
		if (qnameType == null) {
			return null;
		}
		return qnameType;
	}

	private static function getDefaultProperty(classdef:Classdef):String {
		var defaultPropertyMeta = Lambda.find(classdef.meta, item -> item.name == META_DEFAULT_XML_PROPERTY
			|| item.name == ":" + META_DEFAULT_XML_PROPERTY);
		if (defaultPropertyMeta == null) {
			return null;
		}
		if (defaultPropertyMeta.params == null || defaultPropertyMeta.params.length != 1) {
			throw 'The @${defaultPropertyMeta.name} meta must have one property name';
		}
		var propertyName = defaultPropertyMeta.params[0];
		if (propertyName == null || !~/^("|').+\1$/.match(propertyName)) {
			throw 'The @${META_DEFAULT_XML_PROPERTY} meta param must be a string';
			return null;
		}
		return propertyName.substring(1, propertyName.length - 1);
	}
}
