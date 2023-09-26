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
import mxhx.resolver.IMXHXAbstractSymbol;
import mxhx.resolver.IMXHXArgumentSymbol;
import mxhx.resolver.IMXHXClassSymbol;
import mxhx.resolver.IMXHXEnumFieldSymbol;
import mxhx.resolver.IMXHXEnumSymbol;
import mxhx.resolver.IMXHXEventSymbol;
import mxhx.resolver.IMXHXFieldSymbol;
import mxhx.resolver.IMXHXResolver;
import mxhx.resolver.IMXHXSymbol;
import mxhx.resolver.IMXHXTypeSymbol;
import mxhx.resolver.MXHXSymbolTools;

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
		this.parserData = parserData;

		// cache parser data so that lookups are FAST!
		for (parserResult in parserData) {
			for (decl in parserResult.decls) {
				cacheDecl(decl, parserResult.pack);
			}
		}
	}

	private var parserData:Array<{pack:Array<String>, decls:Array<haxeparser.Data.TypeDecl>}>;
	private var manifests:Map<String, Map<String, String>> = [];
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
			var paramsString = qname.substring(paramsIndex + 1, qname.length - 1);
			if (paramsString.length > 0) {
				qnameParams = paramsString.split(",").map(paramTypeName -> resolveQname(paramTypeName));
			}
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
					var param = discoveredParams[0];
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
				return createMXHXClassSymbolForClassDefinition(d, pack, moduleName, qnameParams);
			case EAbstract(d):
				var isEnum = Lambda.find(d.meta, m -> m.name == META_ENUM);
				if (isEnum != null) {
					return createMXHXEnumSymbolForAbstractEnumDefinition(d, pack, moduleName, qnameParams);
				} else {
					return createMXHXAbstractSymbolForAbstractDefinition(d, pack, moduleName, qnameParams, qname);
				}
			case EEnum(d):
				return createMXHXEnumSymbolForEnumDefinition(d, pack, moduleName, qnameParams);
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

	private function fileAndPackToModule(file:String, pack:Array<String>):String {
		var module = "";
		var index = file.lastIndexOf("/");
		for (i in 0...pack.length) {
			index = file.lastIndexOf("/", index - 1);
		}
		return StringTools.replace(file.substring(index + 1, file.length - 3), "/", ".");
	}

	private function resolveImportsForModuleName(moduleToFind:String):Array<TypeDecl> {
		for (parserResult in parserData) {
			for (decl in parserResult.decls) {
				var module = fileAndPackToModule(decl.pos.file, parserResult.pack);
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
		var moduleName = fileAndPackToModule(decl.pos.file, pack);
		var typesInModule = moduleNameToTypesLookup.get(moduleName);
		if (typesInModule == null) {
			typesInModule = [];
			moduleNameToTypesLookup.set(moduleName, typesInModule);
		}
		switch (decl.decl) {
			case EClass(d):
				var qname = definitionAndTypeSymbolParamsToQname(d, pack, moduleName);
				var value = {
					typeDecl: decl,
					pack: pack,
					moduleName: moduleName,
					name: d.name
				};
				qnameToParserTypeLookup.set(qname, value);
				typesInModule.push(value);
			case EAbstract(d):
				var qname = definitionAndTypeSymbolParamsToQname(d, pack, moduleName);
				var value = {
					typeDecl: decl,
					pack: pack,
					moduleName: moduleName,
					name: d.name
				};
				qnameToParserTypeLookup.set(qname, value);
				typesInModule.push(value);
			case EEnum(d):
				var qname = definitionAndTypeSymbolParamsToQname(d, pack, moduleName);
				var value = {
					typeDecl: decl,
					pack: pack,
					moduleName: moduleName,
					name: d.name
				};
				qnameToParserTypeLookup.set(qname, value);
				typesInModule.push(value);
			case ETypedef(d):
				var qname = definitionAndTypeSymbolParamsToQname(d, pack, moduleName);
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
						var param = discoveredParams[0];
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
						var qname = definitionAndTypeSymbolParamsToQname(arrayClassType, [], localName, [itemType]);
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
		return new MXHXFieldSymbol(field.name, resolvedType, isMethod);
	}

	private function createMXHXEnumFieldSymbolForEnumField(enumConstructor:EnumConstructor, parent:IMXHXEnumSymbol, pack:Array<String>, moduleName:String,
			imports:Array<TypeDecl>):IMXHXEnumFieldSymbol {
		var args = enumConstructor.args.map(arg -> createMXHXArgumentSymbolForFunctionArg(arg, pack, moduleName, imports));
		return new MXHXEnumFieldSymbol(enumConstructor.name, parent, args);
	}

	private function createMXHXEnumFieldSymbolForAbstractField(abstractField:Field, parent:IMXHXEnumSymbol):IMXHXEnumFieldSymbol {
		return new MXHXEnumFieldSymbol(abstractField.name, parent, null);
	}

	private function createMXHXArgumentSymbolForFunctionArg(arg:{name:String, opt:Bool, type:ComplexType}, pack:Array<String>, moduleName:String,
			imports:Array<TypeDecl>):IMXHXArgumentSymbol {
		var resolvedType = resolveComplexType(arg.type, pack, moduleName, imports);
		return new MXHXArgumentSymbol(arg.name, resolvedType, arg.opt);
	}

	private function createMXHXClassSymbolForClassDefinition(classType:Definition<ClassFlag, Array<Field>>, pack:Array<String>, moduleName:String,
			params:Array<IMXHXTypeSymbol>):IMXHXClassSymbol {
		var qname = definitionAndTypeSymbolParamsToQname(classType, pack, moduleName, params);
		var result = new MXHXClassSymbol(classType.name, pack);
		result.qname = qname;
		result.module = moduleName;
		// fields may reference this type, so make sure that it's available
		// before parsing anything else
		qnameToMXHXTypeSymbolLookup.set(qname, result);

		var imports = resolveImportsForModuleName(moduleName);
		var resolvedSuperClass:IMXHXClassSymbol = null;
		for (flag in classType.flags) {
			switch (flag) {
				case HExtends(t):
					resolvedSuperClass = cast(resolveComplexType(TPath(t), pack, moduleName, imports), IMXHXClassSymbol);
				default:
			}
		}
		result.superClass = resolvedSuperClass;
		result.params = params != null ? params : [];
		result.fields = classType.data.map(field -> createMXHXFieldSymbolForField(field, pack, moduleName, imports));
		result.events = classType.meta.map(eventMeta -> {
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
		result.defaultProperty = getDefaultProperty(classType);
		return result;
	}

	private function createMXHXAbstractSymbolForAbstractDefinition(abstractType:Definition<AbstractFlag, Array<Field>>, pack:Array<String>, moduleName:String,
			params:Array<IMXHXTypeSymbol>, expectedQname:String):IMXHXAbstractSymbol {
		var qname = definitionAndTypeSymbolParamsToQname(abstractType, pack, moduleName, params);
		var result = new MXHXAbstractSymbol(abstractType.name, pack);
		result.qname = qname;
		result.module = moduleName;
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

	private function createMXHXEnumSymbolForAbstractEnumDefinition(abstractType:Definition<AbstractFlag, Array<Field>>, pack:Array<String>, moduleName:String,
			params:Array<IMXHXTypeSymbol>):IMXHXEnumSymbol {
		var qname = definitionAndTypeSymbolParamsToQname(abstractType, pack, moduleName, params);
		var result = new MXHXEnumSymbol(abstractType.name, pack);
		result.qname = qname;
		result.module = moduleName;
		// fields may reference this type, so make sure that it's available
		// before parsing anything else
		qnameToMXHXTypeSymbolLookup.set(qname, result);

		result.params = params != null ? params : [];
		result.fields = abstractType.data.filter(field -> field.access.indexOf(AStatic) != -1)
			.map(field -> createMXHXEnumFieldSymbolForAbstractField(field, result));
		return result;
	}

	private function createMXHXEnumSymbolForEnumDefinition(enumType:Definition<EnumFlag, Array<EnumConstructor>>, pack:Array<String>, moduleName:String,
			params:Array<IMXHXTypeSymbol>):IMXHXEnumSymbol {
		var qname = definitionAndTypeSymbolParamsToQname(enumType, pack, moduleName, params);
		var result = new MXHXEnumSymbol(enumType.name, pack);
		result.qname = qname;
		result.module = moduleName;
		// fields may reference this type, so make sure that it's available
		// before parsing anything else
		qnameToMXHXTypeSymbolLookup.set(qname, result);

		var imports = resolveImportsForModuleName(moduleName);
		result.params = params != null ? params : [];
		var fields:Array<IMXHXEnumFieldSymbol> = [];
		for (enumConstructor in enumType.data) {
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

	private static function definitionAndTypeSymbolParamsToQname(classType:Definition<Dynamic, Dynamic>, pack:Array<String>, moduleName:String,
			?params:Array<IMXHXTypeSymbol>):String {
		var qname = classType.name;
		if (pack.length > 0) {
			qname = pack.join(".") + "." + qname;
		}
		if (qname != moduleName && moduleName != MODULE_STD_TYPES) {
			qname = moduleName + "." + classType.name;
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
