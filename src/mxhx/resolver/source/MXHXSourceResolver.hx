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

package mxhx.resolver.source;

#if haxeparser
import haxe.macro.Expr.ComplexType;
import haxe.macro.Expr.Field;
import haxe.macro.Expr.MetadataEntry;
import haxe.macro.Expr.Position;
import haxe.macro.Expr.TypeParamDecl;
import haxeparser.Data.AbstractFlag;
import haxeparser.Data.ClassFlag;
import haxeparser.Data.Definition;
import haxeparser.Data.EnumConstructor;
import haxeparser.Data.EnumFlag;
import haxeparser.Data.TypeDecl;
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
import mxhx.resolver.MXHXResolvers;

/**
	An MXHX symbol resolver that uses _.hx_ source files parsed by
	[haxeparser](https://github.com/HaxeCheckstyle/haxeparser).
**/
class MXHXSourceResolver implements IMXHXResolver {
	private static final MODULE_STD_TYPES = "StdTypes";
	private static final TYPE_ARRAY = "Array";
	private static final ATTRIBUTE_TYPE = "type";
	private static final META_DEFAULT_XML_PROPERTY = "defaultXmlProperty";
	private static final META_ENUM = ":enum";

	public function new(parserData:Array<{pack:Array<String>, decls:Array<haxeparser.Data.TypeDecl>}>) {
		manifests = MXHXResolvers.emitMappings();

		this.parserData = parserData;

		// cache parser data so that lookups are FAST!
		for (parserResult in parserData) {
			for (decl in parserResult.decls) {
				cacheDecl(decl, parserResult.pack);
			}
		}
	}

	private var parserData:Array<{pack:Array<String>, decls:Array<haxeparser.Data.TypeDecl>}>;
	private var manifests:Map<String, Map<String, String>> /* Map<Uri<TagName, Qname>> */ = [];
	private var qnameToMXHXTypeSymbolLookup:Map<String, IMXHXTypeSymbol> = [];
	private var qnameToParserTypeLookup:Map<String, TypeDeclEx> = [];
	private var moduleNameToTypesLookup:Map<String, Array<TypeDeclEx>> = [];

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
		var resolved = qnameToMXHXTypeSymbolLookup.get(qname);
		if (resolved != null) {
			return resolved;
		}
		var resolvedParserType = resolveParserTypeForQname(qname);
		if (resolvedParserType == null) {
			return null;
		}
		var originalQname = qname;
		var qnameParams:Array<IMXHXTypeSymbol> = null;
		var paramsIndex = qname.indexOf("<");
		if (paramsIndex != -1) {
			qnameParams = qnameToParams(qname, paramsIndex);
		} else {
			var discoveredParams:Array<TypeParamDecl> = null;
			if (resolvedParserType != null) {
				switch (resolvedParserType.typeDecl.decl) {
					case EClass(d):
						discoveredParams = d.params;
					case EAbstract(d):
						discoveredParams = d.params;
					case EEnum(d):
						discoveredParams = d.params;
					case ETypedef(d):
						discoveredParams = d.params;
					default:
				}
			}
			if (discoveredParams != null && discoveredParams.length > 0) {
				qname += "<";
				for (i in 0...discoveredParams.length) {
					var param = discoveredParams[i];
					if (i > 0) {
						qname += ",";
					}
					var paramQname = param.name;
					if (paramQname == null) {
						paramQname = "%";
					}
					qname += paramQname;
				}
				qname += ">";
			}
		}
		var resolved = qnameToMXHXTypeSymbolLookup.get(qname);
		if (resolved != null) {
			return resolved;
		}
		var typeDecl = resolvedParserType.typeDecl;
		var pack = resolvedParserType.pack;
		var moduleName = resolvedParserType.moduleName;
		switch (typeDecl.decl) {
			case EClass(d):
				if (d.flags.indexOf(HInterface) != -1) {
					return createMXHXInterfaceSymbolForClassDefinition(d, typeDecl.pos, pack, moduleName, qnameParams);
				}
				return createMXHXClassSymbolForClassDefinition(d, typeDecl.pos, pack, moduleName, qnameParams);
			case EAbstract(d):
				var isEnum = Lambda.find(d.meta, m -> m.name == META_ENUM);
				if (isEnum != null) {
					return createMXHXEnumSymbolForAbstractEnumDefinition(d, typeDecl.pos, pack, moduleName, qnameParams);
				} else {
					return createMXHXAbstractSymbolForAbstractDefinition(d, typeDecl.pos, pack, moduleName, qnameParams, qname);
				}
			case EEnum(d):
				return createMXHXEnumSymbolForEnumDefinition(d, typeDecl.pos, pack, moduleName, qnameParams);
			case ETypedef(d):
				var imports = resolveImportsForModuleName(moduleName);
				var result = resolveComplexType(d.data, pack, moduleName, imports);
				if (result != null) {
					qnameToMXHXTypeSymbolLookup.set(originalQname, result);
				}
				return result;
			default:
				trace("unrecognized definition: " + typeDecl.decl);
				return null;
		}
	}

	public function invalidateSymbol(symbol:IMXHXTypeSymbol):Void {
		qnameToMXHXTypeSymbolLookup.remove(symbol.qname);
	}

	public function replaceModule(module:{pack:Array<String>, decls:Array<TypeDecl>}):Void {
		for (decl in module.decls) {
			cacheDecl(decl, module.pack);
		}
		var fileToFind = module.decls[0].pos.file;
		for (i in 0...parserData.length) {
			var otherModule = parserData[i];
			if (otherModule.decls[0].pos.file == fileToFind) {
				parserData[i] = module;
				return;
			}
		}
		parserData.push(module);
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

	private function resolveImportsForModuleName(moduleToFind:String):Array<TypeDecl> {
		for (parserResult in parserData) {
			for (decl in parserResult.decls) {
				var module = MXHXResolverTools.filePathAndPackToModule(decl.pos.file, parserResult.pack);
				if (module == moduleToFind) {
					return parserResult.decls.filter(typeDecl -> {
						return switch (typeDecl.decl) {
							case EImport(sl, mode): true;
							default: false;
						}
					});
				}
				// the rest of the inner loop is the same module,
				// so return to the outer loop
				break;
			}
		}
		return [];
	}

	private function cacheDecl(decl:TypeDecl, pack:Array<String>):Void {
		var moduleName = MXHXResolverTools.filePathAndPackToModule(decl.pos.file, pack);
		var typesInModule = moduleNameToTypesLookup.get(moduleName);
		if (typesInModule == null) {
			typesInModule = [];
			moduleNameToTypesLookup.set(moduleName, typesInModule);
		}
		switch (decl.decl) {
			case EClass(d):
				var qname = MXHXResolverTools.definitionToQname(d.name, pack, moduleName);
				var value = {
					typeDecl: decl,
					pack: pack,
					moduleName: moduleName,
					name: d.name
				};
				qnameToParserTypeLookup.set(qname, value);
				typesInModule.push(value);
			case EAbstract(d):
				var qname = MXHXResolverTools.definitionToQname(d.name, pack, moduleName);
				var value = {
					typeDecl: decl,
					pack: pack,
					moduleName: moduleName,
					name: d.name
				};
				qnameToParserTypeLookup.set(qname, value);
				typesInModule.push(value);
			case EEnum(d):
				var qname = MXHXResolverTools.definitionToQname(d.name, pack, moduleName);
				var value = {
					typeDecl: decl,
					pack: pack,
					moduleName: moduleName,
					name: d.name
				};
				qnameToParserTypeLookup.set(qname, value);
				typesInModule.push(value);
			case ETypedef(d):
				var qname = MXHXResolverTools.definitionToQname(d.name, pack, moduleName);
				var value = {
					typeDecl: decl,
					pack: pack,
					moduleName: moduleName,
					name: d.name
				};
				qnameToParserTypeLookup.set(qname, value);
				typesInModule.push(value);
			default:
				// 	trace("unhandled decl: ", decl.decl);
		}
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
				var resolvedQname = resolveParserTypeForQname(qname);
				var discoveredParams:Array<TypeParamDecl> = null;
				if (resolvedQname != null) {
					switch (resolvedQname.typeDecl.decl) {
						case EClass(d):
							discoveredParams = d.params;
						case EAbstract(d):
							discoveredParams = d.params;
						case EEnum(d):
							discoveredParams = d.params;
						case ETypedef(d):
							discoveredParams = d.params;
						default:
					}
				}
				if (discoveredParams != null && discoveredParams.length > 0) {
					qname += "<";
					for (i in 0...discoveredParams.length) {
						var param = discoveredParams[i];
						if (i > 0) {
							qname += ",";
						}
						var paramQname = null; // parserTypeDefToQname(param);
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
						var arrayType = qnameToParserTypeLookup.get(localName);
						var arrayClassType = switch (arrayType.typeDecl.decl) {
							case EClass(d): d;
							default: null;
						}
						var itemType:IMXHXTypeSymbol = resolveQname(typeAttr.rawValue);
						if (tagData.stateName != null) {
							return null;
						}
						var qname = MXHXResolverTools.definitionToQname(arrayClassType.name, [], localName, [itemType.qname]);
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

	private function resolveComplexType(complexType:ComplexType, pack:Array<String>, moduleName:String, imports:Array<TypeDecl>):IMXHXTypeSymbol {
		if (complexType == null) {
			return null;
		}
		var joinedPack = pack.join(".");
		switch (complexType) {
			case TPath(p):
				var baseName = p.name;
				var qname = baseName;
				if (p.pack.length > 0) {
					qname = p.pack.join(".") + "." + baseName;
				} else {
					var foundImport = false;
					for (current in imports) {
						switch (current.decl) {
							case EImport(sl, mode):
								switch (mode) {
									case INormal:
										var lastPart = sl[sl.length - 1].pack;
										if (lastPart == baseName) {
											qname = sl.map(part -> part.pack).join(".");
											foundImport = true;
											break;
										}
									case IAsName(s):
										if (s == baseName) {
											qname = sl.map(part -> part.pack).join(".");
											foundImport = true;
											break;
										}
									case IAll:
										var possibleQname = sl.map(item -> item.pack).join(".") + "." + baseName;
										var resolved = resolveQname(possibleQname);
										if (resolved != null) {
											qname = possibleQname;
											foundImport = true;
											break;
										}
									default:
										trace("unrecognized import: " + current.decl);
								}
							default:
								// not an import
						}
					}
					if (!foundImport && joinedPack.length > 0) {
						var inPackQname = joinedPack + "." + baseName;
						var inPackageType = qnameToParserTypeLookup.get(inPackQname);
						if (inPackageType != null) {
							qname = inPackQname;
							foundImport = true;
						}
					}
				}
				if (p.params != null && p.params.length > 0) {
					qname += "<";
					for (i in 0...p.params.length) {
						var param = p.params[i];
						if (i > 0) {
							qname += ",";
						}
						var complexType = switch (param) {
							case TPType(t):
								resolveComplexType(t, pack, moduleName, imports);
							default:
								null;
						}
						qname += complexType != null ? complexType.qname : "%";
					}
					qname += ">";
				}
				return resolveQname(qname);
			case TFunction(args, ret):
				return resolveQname("haxe.Constraints.Function");
			case TAnonymous(fields):
				return resolveQname("Dynamic");
			case TIntersection(tl):
				return resolveQname("Dynamic");
			default:
				trace("unhandled complex type: " + complexType);
				return null;
		}
	}

	private function createMXHXFieldSymbolForField(field:Field, pack:Array<String>, moduleName:String, imports:Array<TypeDecl>):IMXHXFieldSymbol {
		var resolvedType = switch (field.kind) {
			case FVar(t, e):
				resolveComplexType(t, pack, moduleName, imports);
			case FProp(get, set, t, e):
				resolveComplexType(t, pack, moduleName, imports);
			case FFun(f):
				resolveComplexType(f.ret, pack, moduleName, imports);
			default: null;
		}
		var isMethod = switch (field.kind) {
			case FFun(f): true;
			default: null;
		}
		var isPublic = field.access != null && field.access.indexOf(APublic) != -1;
		var isStatic = field.access != null && field.access.indexOf(AStatic) != -1;
		var result = new MXHXFieldSymbol(field.name, resolvedType, isMethod, isPublic, isStatic);
		result.doc = field.doc;
		result.file = field.pos.file;
		result.offsets = {start: field.pos.min, end: field.pos.max};
		return result;
	}

	private function createMXHXEnumFieldSymbolForEnumField(enumConstructor:EnumConstructor, parent:IMXHXEnumSymbol, pack:Array<String>, moduleName:String,
			imports:Array<TypeDecl>):IMXHXEnumFieldSymbol {
		var args = enumConstructor.args.map(arg -> createMXHXArgumentSymbolForFunctionArg(arg, pack, moduleName, imports));
		var result = new MXHXEnumFieldSymbol(enumConstructor.name, parent, args);
		result.doc = enumConstructor.doc;
		return result;
	}

	private function createMXHXEnumFieldSymbolForAbstractField(abstractField:Field, parent:IMXHXEnumSymbol):IMXHXEnumFieldSymbol {
		var result = new MXHXEnumFieldSymbol(abstractField.name, parent, null);
		result.doc = abstractField.doc;
		return result;
	}

	private function createMXHXArgumentSymbolForFunctionArg(arg:{name:String, opt:Bool, type:ComplexType}, pack:Array<String>, moduleName:String,
			imports:Array<TypeDecl>):IMXHXArgumentSymbol {
		var resolvedType = resolveComplexType(arg.type, pack, moduleName, imports);
		return new MXHXArgumentSymbol(arg.name, resolvedType, arg.opt);
	}

	private function createMXHXInterfaceSymbolForClassDefinition(classDefinition:Definition<ClassFlag, Array<Field>>, pos:Position, pack:Array<String>,
			moduleName:String, params:Array<IMXHXTypeSymbol>):IMXHXInterfaceSymbol {
		var qname = MXHXResolverTools.definitionToQname(classDefinition.name, pack, moduleName,
			params != null ? params.map(param -> param != null ? param.qname : null) : null);
		var result = new MXHXInterfaceSymbol(classDefinition.name, pack);
		result.qname = qname;
		result.module = moduleName;
		result.doc = classDefinition.doc;
		result.file = pos.file;
		result.offsets = {start: pos.min, end: pos.max};
		// fields may reference this type, so make sure that it's available
		// before parsing anything else
		qnameToMXHXTypeSymbolLookup.set(qname, result);

		var imports = resolveImportsForModuleName(moduleName);
		var resolvedInterfaces:Array<IMXHXInterfaceSymbol> = [];
		for (flag in classDefinition.flags) {
			switch (flag) {
				case HImplements(t):
					var resolvedImplements = resolveComplexType(TPath(t), pack, moduleName, imports);
					if ((resolvedImplements is IMXHXInterfaceSymbol)) {
						var resolvedInterface:IMXHXInterfaceSymbol = cast resolvedImplements;
						resolvedInterfaces.push(resolvedInterface);
					}
				default:
			}
		}
		result.interfaces = resolvedInterfaces;
		result.params = params != null ? params : [];
		result.fields = classDefinition.data.map(field -> createMXHXFieldSymbolForField(field, pack, moduleName, imports));
		return result;
	}

	private function createMXHXClassSymbolForClassDefinition(classDefinition:Definition<ClassFlag, Array<Field>>, pos:Position, pack:Array<String>,
			moduleName:String, params:Array<IMXHXTypeSymbol>):IMXHXClassSymbol {
		var qname = MXHXResolverTools.definitionToQname(classDefinition.name, pack, moduleName,
			params != null ? params.map(param -> param != null ? param.qname : null) : null);
		var result = new MXHXClassSymbol(classDefinition.name, pack);
		result.qname = qname;
		result.module = moduleName;
		result.doc = classDefinition.doc;
		result.file = pos.file;
		result.offsets = {start: pos.min, end: pos.max};
		// fields may reference this type, so make sure that it's available
		// before parsing anything else
		qnameToMXHXTypeSymbolLookup.set(qname, result);

		var imports = resolveImportsForModuleName(moduleName);
		var resolvedSuperClass:IMXHXClassSymbol = null;
		var resolvedInterfaces:Array<IMXHXInterfaceSymbol> = [];
		for (flag in classDefinition.flags) {
			switch (flag) {
				case HExtends(t):
					var resolvedExtends = resolveComplexType(TPath(t), pack, moduleName, imports);
					if ((resolvedExtends is IMXHXClassSymbol)) {
						resolvedSuperClass = cast resolvedExtends;
					}
				case HImplements(t):
					var resolvedImplements = resolveComplexType(TPath(t), pack, moduleName, imports);
					if ((resolvedImplements is IMXHXInterfaceSymbol)) {
						var resolvedInterface:IMXHXInterfaceSymbol = cast resolvedImplements;
						resolvedInterfaces.push(resolvedInterface);
					}
				default:
			}
		}
		result.superClass = resolvedSuperClass;
		result.interfaces = resolvedInterfaces;
		result.params = params != null ? params : [];
		result.fields = classDefinition.data.map(field -> createMXHXFieldSymbolForField(field, pack, moduleName, imports));
		result.events = classDefinition.meta.map(eventMeta -> {
			if (eventMeta.name != ":event") {
				return null;
			}
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
		result.defaultProperty = getDefaultProperty(classDefinition);
		return result;
	}

	private function createMXHXAbstractSymbolForAbstractDefinition(abstractDefinition:Definition<AbstractFlag, Array<Field>>, pos:Position,
			pack:Array<String>, moduleName:String, params:Array<IMXHXTypeSymbol>, expectedQname:String):IMXHXAbstractSymbol {
		var qname = MXHXResolverTools.definitionToQname(abstractDefinition.name, pack, moduleName,
			params != null ? params.map(param -> param != null ? param.qname : null) : null);
		var result = new MXHXAbstractSymbol(abstractDefinition.name, pack);
		result.qname = qname;
		result.module = moduleName;
		result.doc = abstractDefinition.doc;
		result.file = pos.file;
		result.offsets = {start: pos.min, end: pos.max};
		if (moduleName == MODULE_STD_TYPES) {
			qnameToMXHXTypeSymbolLookup.set(MODULE_STD_TYPES + "." + qname, result);
		}
		// fields may reference this type, so make sure that it's available
		// before parsing anything else
		qnameToMXHXTypeSymbolLookup.set(qname, result);

		result.params = params != null ? params : [];
		// result.from = abstractType.from.map(from -> {
		// 	var qname = parserTypeDefToQname(from.t);
		// 	return resolveQname(qname);
		// });
		return result;
	}

	private function createMXHXEnumSymbolForAbstractEnumDefinition(abstractDefinition:Definition<AbstractFlag, Array<Field>>, pos:Position,
			pack:Array<String>, moduleName:String, params:Array<IMXHXTypeSymbol>):IMXHXEnumSymbol {
		var qname = MXHXResolverTools.definitionToQname(abstractDefinition.name, pack, moduleName,
			params != null ? params.map(param -> param != null ? param.qname : null) : null);
		var result = new MXHXEnumSymbol(abstractDefinition.name, pack);
		result.qname = qname;
		result.module = moduleName;
		result.doc = abstractDefinition.doc;
		result.file = pos.file;
		result.offsets = {start: pos.min, end: pos.max};
		// fields may reference this type, so make sure that it's available
		// before parsing anything else
		qnameToMXHXTypeSymbolLookup.set(qname, result);

		result.params = params != null ? params : [];
		result.fields = abstractDefinition.data.filter(field -> field.access.indexOf(AStatic) != -1)
			.map(field -> createMXHXEnumFieldSymbolForAbstractField(field, result));
		return result;
	}

	private function createMXHXEnumSymbolForEnumDefinition(enumDefinition:Definition<EnumFlag, Array<EnumConstructor>>, pos:Position, pack:Array<String>,
			moduleName:String, params:Array<IMXHXTypeSymbol>):IMXHXEnumSymbol {
		var qname = MXHXResolverTools.definitionToQname(enumDefinition.name, pack, moduleName,
			params != null ? params.map(param -> param != null ? param.qname : null) : null);
		var result = new MXHXEnumSymbol(enumDefinition.name, pack);
		result.qname = qname;
		result.module = moduleName;
		result.doc = enumDefinition.doc;
		result.file = pos.file;
		result.offsets = {start: pos.min, end: pos.max};
		// fields may reference this type, so make sure that it's available
		// before parsing anything else
		qnameToMXHXTypeSymbolLookup.set(qname, result);

		var imports = resolveImportsForModuleName(moduleName);
		result.params = params != null ? params : [];
		var fields:Array<IMXHXEnumFieldSymbol> = [];
		for (enumConstructor in enumDefinition.data) {
			fields.push(createMXHXEnumFieldSymbolForEnumField(enumConstructor, result, pack, moduleName, imports));
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
			throw "getEventNames() requires :event meta";
		}
		var typedExprDef = null; // Context.typeExpr(eventMeta.params[0]).expr;
		if (typedExprDef == null) {
			return null;
		}
		// var result:String = null;
		// while (true) {
		// 	switch (typedExprDef) {
		// 		case TConst(TString(s)):
		// 			return s;
		// 		case TCast(e, _):
		// 			typedExprDef = e.expr;
		// 		case TField(e, FStatic(c, cf)):
		// 			var classField = cf.get();
		// 			var classFieldExpr = classField.expr();
		// 			if (classFieldExpr == null) {
		// 				// can't find the string value, so generate it from the
		// 				// name of the field based on standard naming convention
		// 				var parts = classField.name.split("_");
		// 				var result = "";
		// 				for (i in 0...parts.length) {
		// 					var part = parts[i].toLowerCase();
		// 					if (i == 0) {
		// 						result += part;
		// 					} else {
		// 						result += part.charAt(0).toUpperCase() + part.substr(1);
		// 					}
		// 				}
		// 				return result;
		// 			}
		// 			typedExprDef = classField.expr().expr;
		// 		default:
		// 			return null;
		// 	}
		// }
		return null;
	}

	/**
		Gets the type of an event from an `:event` metadata entry.
	**/
	private static function getEventType(eventMeta:MetadataEntry):String {
		if (eventMeta.name != ":event") {
			throw "getEventType() requires :event meta";
		}
		var typedExprType = null; // Context.typeExpr(eventMeta.params[0]).t;
		return switch (typedExprType) {
			// case TAbstract(t, params):
			// 	var qname = macroBaseTypeToQname(t.get());
			// 	if ("openfl.events.EventType" != qname) {
			// 		return "openfl.events.Event";
			// 	}
			// 	switch (params[0]) {
			// 		case TInst(t, params): t.toString();
			// 		default: null;
			// 	}
			case null: "openfl.events.Event";
			default: "openfl.events.Event";
		};
	}

	private static function getDefaultProperty(t:Definition<Dynamic, Dynamic>):String {
		var defaultPropertyMeta = Lambda.find(t.meta, item -> item.name == META_DEFAULT_XML_PROPERTY
			|| item.name == ":" + META_DEFAULT_XML_PROPERTY);
		if (defaultPropertyMeta == null) {
			return null;
		}
		if (defaultPropertyMeta.params == null || defaultPropertyMeta.params.length != 1) {
			throw 'The @${defaultPropertyMeta.name} meta must have one property name';
		}
		var param = defaultPropertyMeta.params[0];
		var propertyName:String = null;
		switch (param.expr) {
			case EConst(c):
				switch (c) {
					case CString(s, kind): propertyName = s;
					default:
				}
			default:
		}
		if (propertyName == null) {
			throw 'The @${META_DEFAULT_XML_PROPERTY} meta param must be a string';
			return null;
		}
		return propertyName;
	}

	private function resolveParserTypeForQname(qnameToFind:String):TypeDeclEx {
		var paramIndex = qnameToFind.indexOf("<");
		if (paramIndex != -1) {
			qnameToFind = qnameToFind.substr(0, paramIndex);
		}

		var resolvedType = qnameToParserTypeLookup.get(qnameToFind);
		if (resolvedType != null) {
			return resolvedType;
		}

		// next, try to determine if it's in a module, but not the main type
		var moduleName = qnameToFind;
		var lastDotIndex = qnameToFind.lastIndexOf(".");
		if (lastDotIndex != -1) {
			moduleName = qnameToFind.substring(0, lastDotIndex);
			try {
				var typesInModule = moduleNameToTypesLookup.get(moduleName);
				if (typesInModule != null) {
					resolvedType = Lambda.find(typesInModule, type -> {
						var moduleTypeQname = type.moduleName;
						if (moduleTypeQname != type.name && !StringTools.endsWith(moduleTypeQname, "." + type.name)) {
							moduleTypeQname += "." + type.name;
						}
						var paramIndex = moduleTypeQname.indexOf("<");
						if (paramIndex != -1) {
							moduleTypeQname = moduleTypeQname.substr(0, paramIndex);
						}
						return moduleTypeQname == qnameToFind;
					});
				}
			} catch (e:Dynamic) {}
		}
		if (resolvedType != null) {
			qnameToParserTypeLookup.set(qnameToFind, resolvedType);
		}
		return resolvedType;
	}
}

private typedef TypeDeclEx = {
	typeDecl:TypeDecl,
	pack:Array<String>,
	moduleName:String,
	name:String,
}
#end
