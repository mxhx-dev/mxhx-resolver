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

package mxhx.resolver.macro;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr.Error;
import haxe.macro.Expr.MetadataEntry;
import haxe.macro.Type;
import mxhx.internal.resolver.MXHXAbstractSymbol;
import mxhx.internal.resolver.MXHXArgumentSymbol;
import mxhx.internal.resolver.MXHXClassSymbol;
import mxhx.internal.resolver.MXHXEnumFieldSymbol;
import mxhx.internal.resolver.MXHXEnumSymbol;
import mxhx.internal.resolver.MXHXEventSymbol;
import mxhx.internal.resolver.MXHXFieldSymbol;
import mxhx.internal.resolver.MXHXInterfaceSymbol;
import mxhx.resolver.IMXHXAbstractSymbol;
import mxhx.resolver.IMXHXArgumentSymbol;
import mxhx.resolver.IMXHXClassSymbol;
import mxhx.resolver.IMXHXEnumFieldSymbol;
import mxhx.resolver.IMXHXEnumSymbol;
import mxhx.resolver.IMXHXEventSymbol;
import mxhx.resolver.IMXHXFieldSymbol;
import mxhx.resolver.IMXHXInterfaceSymbol;
import mxhx.resolver.IMXHXResolver;
import mxhx.resolver.IMXHXSymbol;
import mxhx.resolver.IMXHXTypeSymbol;
import mxhx.resolver.MXHXSymbolTools;

/**
	An MXHX resolver that uses the [Haxe Macro Context](https://haxe.org/manual/macro-context.html)
	to resolve symbols.
**/
class MXHXMacroResolver implements IMXHXResolver {
	private static final MODULE_STD_TYPES = "StdTypes";
	private static final TYPE_ARRAY = "Array";
	private static final ATTRIBUTE_TYPE = "type";
	private static final META_DEFAULT_XML_PROPERTY = "defaultXmlProperty";
	private static final META_ENUM = ":enum";

	public function new() {}

	private var manifests:Map<String, Map<String, String>> = [];
	private var qnameLookup:Map<String, IMXHXTypeSymbol> = [];

	/**
		Registers the classes available in a particular MXHX namespace.
	**/
	public function registerManifest(uri:String, mappings:Map<String, String>):Void {
		manifests.set(uri, mappings);
	}

	/**
		Resolves the symbol that a tag represents.
	**/
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

	/**
		Resolves the symbol that an MXHX tag attribute represents.
	**/
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

	/**
		Resolves a field of a tag.
	**/
	public function resolveTagField(tag:IMXHXTagData, fieldName:String):IMXHXFieldSymbol {
		var tagSymbol = resolveTag(tag);
		if (tagSymbol == null || !(tagSymbol is IMXHXClassSymbol)) {
			return null;
		}

		var classSymbol:IMXHXClassSymbol = cast tagSymbol;
		return MXHXSymbolTools.resolveFieldByName(classSymbol, fieldName);
	}

	/**
		Resolves a type from its fully-qualified name.
	**/
	public function resolveQname(qname:String):IMXHXTypeSymbol {
		if (qname == null) {
			return null;
		}
		var qnameMacroType = resolveMacroTypeForQname(qname);
		if (qnameMacroType == null) {
			return null;
		}
		var qnameParams:Array<IMXHXTypeSymbol>;
		var paramsIndex = qname.indexOf("<");
		if (paramsIndex != -1) {
			var paramsString = qname.substring(paramsIndex + 1, qname.length - 1);
			if (paramsString.length > 0) {
				qnameParams = paramsString.split(",").map(paramTypeName -> resolveQname(paramTypeName));
			}
		} else {
			var discoveredParams:Array<Type> = null;
			if (qnameMacroType != null) {
				switch (qnameMacroType) {
					case TInst(t, params):
						discoveredParams = params;
					case TAbstract(t, params):
						var abstractType = t.get();
						discoveredParams = params;
					case TEnum(t, params):
						discoveredParams = params;
					default:
				}
			}
			if (discoveredParams != null && discoveredParams.length > 0) {
				qname += "<";
				for (i in 0...discoveredParams.length) {
					var param = discoveredParams[0];
					if (i > 0) {
						qname += ",";
					}
					var paramQname = macroTypeToQname(param);
					if (paramQname == null) {
						paramQname = "%";
					}
					qname += paramQname;
				}
				qname += ">";
			}
		}
		var resolved = qnameLookup.get(qname);
		if (resolved != null) {
			return resolved;
		}
		switch (qnameMacroType) {
			case TInst(t, params):
				var classType = t.get();
				if (classType.isInterface) {
					return createMXHXInterfaceSymbolForClassType(classType, qnameParams);
				}
				return createMXHXClassSymbolForClassType(classType, qnameParams);
			case TAbstract(t, params):
				var abstractType = t.get();
				if (abstractType.meta.has(META_ENUM)) {
					return createMXHXEnumSymbolForAbstractEnumType(abstractType, qnameParams);
				} else {
					return createMXHXAbstractSymbolForAbstractType(abstractType, qnameParams);
				}
			case TEnum(t, params):
				var enumType = t.get();
				return createMXHXEnumSymbolForEnumType(enumType, qnameParams);
			default:
				return null;
		}
	}

	public function invalidateSymbol(symbol:IMXHXTypeSymbol):Void {
		qnameLookup.remove(symbol.qname);
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
				var qnameMacroType = resolveMacroTypeForQname(qname);
				var discoveredParams:Array<Type> = null;
				if (qnameMacroType != null) {
					switch (qnameMacroType) {
						case TInst(t, params):
							discoveredParams = params;
						case TAbstract(t, params):
							discoveredParams = params;
						case TEnum(t, params):
							discoveredParams = params;
						default:
					}
				}
				if (discoveredParams != null && discoveredParams.length > 0) {
					qname += "<";
					for (i in 0...discoveredParams.length) {
						var param = discoveredParams[0];
						if (i > 0) {
							qname += ",";
						}
						var paramQname = macroTypeToQname(param);
						if (paramQname == null) {
							paramQname = "%";
						}
						qname += paramQname;
					}
					qname += ">";
				}
				if (localName == TYPE_ARRAY) {
					var typeAttr = tagData.getAttributeData(ATTRIBUTE_TYPE);
					if (typeAttr != null) {
						var arrayType = Context.getType(localName);
						var arrayClassType = switch (arrayType) {
							case TInst(t, params): t.get();
							default: null;
						}
						var itemType:IMXHXTypeSymbol = resolveQname(typeAttr.rawValue);
						if (tagData.stateName != null) {
							return null;
						}
						var qname = macroBaseTypeAndTypeSymbolParamsToQname(arrayClassType, [itemType]);
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

	private function createMXHXFieldSymbolForClassField(classField:ClassField):IMXHXFieldSymbol {
		var resolvedType:IMXHXTypeSymbol = null;
		var typeQname = macroTypeToQname(classField.type);
		if (typeQname != null) {
			resolvedType = resolveQname(typeQname);
		}
		var isMethod = switch (classField.kind) {
			case FMethod(k): true;
			default: null;
		}
		return new MXHXFieldSymbol(classField.name, resolvedType, isMethod);
	}

	private function createMXHXEnumFieldSymbolForEnumField(enumField:EnumField, parent:IMXHXEnumSymbol):IMXHXEnumFieldSymbol {
		var args:Array<IMXHXArgumentSymbol> = null;
		switch (enumField.type) {
			case TFun(funArgs, funRet):
				args = funArgs.map(arg -> createMXHXArgumentSymbolForFunctionArg(arg));
			default:
		}
		return new MXHXEnumFieldSymbol(enumField.name, parent, args);
	}

	private function createMXHXEnumFieldSymbolForAbstractField(abstractField:ClassField, parent:IMXHXEnumSymbol):IMXHXEnumFieldSymbol {
		return new MXHXEnumFieldSymbol(abstractField.name, parent, null);
	}

	private function createMXHXArgumentSymbolForFunctionArg(functionArg:{name:String, opt:Bool, t:Type}):IMXHXArgumentSymbol {
		var qname = macroTypeToQname(functionArg.t);
		var resolvedType = resolveQname(qname);
		return new MXHXArgumentSymbol(functionArg.name, resolvedType, functionArg.opt);
	}

	private function createMXHXInterfaceSymbolForClassType(classType:ClassType, params:Array<IMXHXTypeSymbol>):IMXHXInterfaceSymbol {
		var qname = macroBaseTypeAndTypeSymbolParamsToQname(classType, params);
		var result = new MXHXInterfaceSymbol(classType.name, classType.pack.copy());
		result.qname = qname;
		result.module = classType.module;
		// fields may reference this type, so make sure that it's available
		// before parsing anything else
		qnameLookup.set(qname, result);

		result.interfaces = classType.interfaces.map(i -> {
			var interfaceType = i.t.get();
			var interfaceQName = macroBaseTypeToQname(interfaceType, i.params);
			return cast resolveQname(interfaceQName);
		});
		result.params = params != null ? params : [];
		result.fields = classType.fields.get().map(classField -> createMXHXFieldSymbolForClassField(classField));

		return result;
	}

	private function createMXHXClassSymbolForClassType(classType:ClassType, params:Array<IMXHXTypeSymbol>):IMXHXClassSymbol {
		var qname = macroBaseTypeAndTypeSymbolParamsToQname(classType, params);
		var result = new MXHXClassSymbol(classType.name, classType.pack.copy());
		result.qname = qname;
		result.module = classType.module;
		// fields may reference this type, so make sure that it's available
		// before parsing anything else
		qnameLookup.set(qname, result);

		var resolvedSuperClass:IMXHXClassSymbol = null;
		if (classType.superClass != null) {
			var superClass = classType.superClass.t.get();
			var superClassQName = macroBaseTypeToQname(superClass, classType.superClass.params);
			resolvedSuperClass = cast resolveQname(superClassQName);
		}
		result.superClass = resolvedSuperClass;
		result.interfaces = classType.interfaces.map(i -> {
			var interfaceType = i.t.get();
			var interfaceQName = macroBaseTypeToQname(interfaceType, i.params);
			return cast resolveQname(interfaceQName);
		});
		result.params = params != null ? params : [];
		result.fields = classType.fields.get().map(classField -> createMXHXFieldSymbolForClassField(classField));
		result.events = classType.meta.extract(":event").map(eventMeta -> {
			if (eventMeta.params.length != 1) {
				return null;
			}
			var eventName = getEventName(eventMeta);
			if (eventName == null) {
				return null;
			}
			var eventTypeQname = getEventType(eventMeta);
			var resolvedType:IMXHXClassSymbol = cast resolveQname(eventTypeQname);
			var result:IMXHXEventSymbol = new MXHXEventSymbol(eventName, resolvedType);
			return result;
		}).filter(eventSymbol -> eventSymbol != null);
		result.defaultProperty = getDefaultProperty(classType);
		return result;
	}

	private function createMXHXAbstractSymbolForAbstractType(abstractType:AbstractType, params:Array<IMXHXTypeSymbol>):IMXHXAbstractSymbol {
		var qname = macroBaseTypeAndTypeSymbolParamsToQname(abstractType, params);

		var result = new MXHXAbstractSymbol(abstractType.name, abstractType.pack.copy());
		result.qname = qname;
		result.module = abstractType.module;
		// fields may reference this type, so make sure that it's available
		// before parsing anything else
		qnameLookup.set(qname, result);

		result.params = params != null ? params : [];
		result.from = abstractType.from.map(from -> {
			var qname = macroTypeToQname(from.t);
			return resolveQname(qname);
		});
		return result;
	}

	private function createMXHXEnumSymbolForAbstractEnumType(abstractType:AbstractType, params:Array<IMXHXTypeSymbol>):IMXHXEnumSymbol {
		var qname = macroBaseTypeAndTypeSymbolParamsToQname(abstractType, params);
		var result = new MXHXEnumSymbol(abstractType.name, abstractType.pack.copy());
		result.qname = qname;
		result.module = abstractType.module;
		// fields may reference this type, so make sure that it's available
		// before parsing anything else
		qnameLookup.set(qname, result);

		result.params = params != null ? params : [];
		result.fields = abstractType.impl.get().statics.get().map(field -> createMXHXEnumFieldSymbolForAbstractField(field, result));
		return result;
	}

	private function createMXHXEnumSymbolForEnumType(enumType:EnumType, params:Array<IMXHXTypeSymbol>):IMXHXEnumSymbol {
		var qname = macroBaseTypeAndTypeSymbolParamsToQname(enumType, params);
		var result = new MXHXEnumSymbol(enumType.name, enumType.pack.copy());
		result.qname = qname;
		result.module = enumType.module;
		// fields may reference this type, so make sure that it's available
		// before parsing anything else
		qnameLookup.set(qname, result);

		result.params = params != null ? params : [];
		var fields:Array<IMXHXEnumFieldSymbol> = [];
		for (key => value in enumType.constructs) {
			fields.push(createMXHXEnumFieldSymbolForEnumField(value, result));
		}
		result.fields = fields;
		return result;
	}

	private function hasValidPrefix(tag:IMXHXTagData):Bool {
		var prefixMap = tag.compositePrefixMap;
		if (prefixMap == null) {
			return false;
		}
		return prefixMap.containsPrefix(tag.prefix) && prefixMap.containsUri(tag.uri);
	}

	private static function getEventName(eventMeta:MetadataEntry):String {
		if (eventMeta.name != ":event") {
			throw new Error("getEventNames() requires :event meta", Context.currentPos());
		}
		var typedExprDef = Context.typeExpr(eventMeta.params[0]).expr;
		if (typedExprDef == null) {
			return null;
		}
		var result:String = null;
		while (true) {
			switch (typedExprDef) {
				case TConst(TString(s)):
					return s;
				case TCast(e, _):
					typedExprDef = e.expr;
				case TField(e, FStatic(c, cf)):
					var classField = cf.get();
					var classFieldExpr = classField.expr();
					if (classFieldExpr == null) {
						// can't find the string value, so generate it from the
						// name of the field based on standard naming convention
						var parts = classField.name.split("_");
						var result = "";
						for (i in 0...parts.length) {
							var part = parts[i].toLowerCase();
							if (i == 0) {
								result += part;
							} else {
								result += part.charAt(0).toUpperCase() + part.substr(1);
							}
						}
						return result;
					}
					typedExprDef = classField.expr().expr;
				default:
					return null;
			}
		}
		return null;
	}

	/**
		Gets the type of an event from an `:event` metadata entry.
	**/
	private static function getEventType(eventMeta:MetadataEntry):String {
		if (eventMeta.name != ":event") {
			throw new Error("getEventType() requires :event meta", Context.currentPos());
		}
		var typedExprType = Context.typeExpr(eventMeta.params[0]).t;
		return switch (typedExprType) {
			case TAbstract(t, params):
				var qname = macroBaseTypeToQname(t.get());
				if ("openfl.events.EventType" != qname) {
					return "openfl.events.Event";
				}
				switch (params[0]) {
					case TInst(t, params): t.toString();
					default: null;
				}
			default: "openfl.events.Event";
		};
	}

	private static function getDefaultProperty(t:BaseType):String {
		var metaDefaultXmlProperty = META_DEFAULT_XML_PROPERTY;
		if (!t.meta.has(metaDefaultXmlProperty)) {
			metaDefaultXmlProperty = ":" + metaDefaultXmlProperty;
			if (!t.meta.has(metaDefaultXmlProperty)) {
				return null;
			}
		}
		var defaultPropertyMeta = t.meta.extract(metaDefaultXmlProperty)[0];
		if (defaultPropertyMeta.params.length != 1) {
			throw new Error('The @${metaDefaultXmlProperty} meta must have one property name', defaultPropertyMeta.pos);
		}
		var param = defaultPropertyMeta.params[0];
		var propertyName:String = null;
		switch (param.expr) {
			case EConst(c):
				switch (c) {
					case CString(s, kind):
						propertyName = s;
					default:
				}
			default:
		}
		if (propertyName == null) {
			throw new Error('The @${META_DEFAULT_XML_PROPERTY} meta param must be a string', param.pos);
			return null;
		}
		return propertyName;
	}

	private static function macroTypeToQname(type:Type):String {
		var current = type;
		while (current != null) {
			switch (current) {
				case TInst(t, params):
					var classType = t.get();
					switch (classType.kind) {
						case KTypeParameter(constraints):
							return null;
						default:
					}
					return macroBaseTypeToQname(classType, params);
				case TEnum(t, params):
					var enumType = t.get();
					return macroBaseTypeToQname(enumType, params);
				case TAbstract(t, params):
					var abstractType = t.get();
					return macroBaseTypeToQname(abstractType, params);
				case TDynamic(t):
					return "Dynamic<%>";
				case TFun(args, ret):
					return "haxe.Constraints.Function";
				case TMono(t):
					current = t.get();
				case TType(t, params):
					current = t.get().type;
				case TLazy(f):
					try {
						current = f();
					} catch (e:Dynamic) {
						// avoid Accessing a type while it's being typed exception
						return null;
					}
				default:
					return null;
			}
		}
		return null;
	}

	/**
		Extracts the qname from a macro BaseType
	**/
	private static function macroBaseTypeToQname(baseType:BaseType, ?params:Array<Type>):String {
		var qname = baseType.name;
		if (baseType.pack.length > 0) {
			qname = baseType.pack.join(".") + "." + qname;
		}
		if (qname != baseType.module && baseType.module != MODULE_STD_TYPES) {
			qname = baseType.module + "." + baseType.name;
		}
		if (params != null && params.length > 0) {
			qname += "<";
			for (i in 0...params.length) {
				var param = params[0];
				if (i > 0) {
					qname += ",";
				}
				var paramQname = macroTypeToQname(param);
				if (paramQname == null) {
					paramQname = "%";
				}
				qname += paramQname;
			}
			qname += ">";
		}
		return qname;
	}

	private static function macroBaseTypeAndTypeSymbolParamsToQname(baseType:BaseType, ?params:Array<IMXHXTypeSymbol>):String {
		var qname = baseType.name;
		if (baseType.pack.length > 0) {
			qname = baseType.pack.join(".") + "." + qname;
		}
		if (qname != baseType.module && baseType.module != MODULE_STD_TYPES) {
			qname = baseType.module + "." + baseType.name;
		}
		if (params != null && params.length > 0) {
			qname += "<";
			for (i in 0...params.length) {
				var param = params[0];
				if (i > 0) {
					qname += ",";
				}
				if (param == null) {
					qname += "%";
				} else {
					qname += param.qname;
				}
			}
			qname += ">";
		}
		return qname;
	}

	private static function resolveMacroTypeForQname(qname:String):Type {
		var paramIndex = qname.indexOf("<");
		if (paramIndex != -1) {
			qname = qname.substr(0, paramIndex);
		}

		// first try to find the qname by module
		// we need to do this because types with @:generic will cause the Haxe
		// compiler to crash when we omit the type parameter for
		// Context.getType(). it won't throw. it will just crash!
		var resolvedType:Type = null;
		try {
			resolvedType = Lambda.find(Context.getModule(qname), type -> {
				var moduleTypeQname = macroTypeToQname(type);
				var paramIndex = moduleTypeQname.indexOf("<");
				if (paramIndex != -1) {
					moduleTypeQname = moduleTypeQname.substr(0, paramIndex);
				}
				return moduleTypeQname == qname;
			});
		} catch (e:Dynamic) {}
		if (resolvedType == null) {
			// next, try to determine if it's in a module, but not the main type
			var moduleName = qname;
			if (qname.indexOf(".") != -1) {
				var qnameParts = qname.split(".");
				qnameParts.pop();
				moduleName = qnameParts.join(".");
				try {
					resolvedType = Lambda.find(Context.getModule(moduleName), type -> {
						var moduleTypeQname = macroTypeToQname(type);
						var paramIndex = moduleTypeQname.indexOf("<");
						if (paramIndex != -1) {
							moduleTypeQname = moduleTypeQname.substr(0, paramIndex);
						}
						return moduleTypeQname == qname;
					});
				} catch (e:Dynamic) {}
			}
			if (resolvedType == null) {
				// final fallback to Context.getType()
				try {
					resolvedType = Context.getType(qname);
				} catch (e:Dynamic) {}
			}
		}
		return resolvedType;
	}
}
#end
