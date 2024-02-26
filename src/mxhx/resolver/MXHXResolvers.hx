package mxhx.resolver;

import haxe.macro.Expr;
#if macro
import haxe.macro.Context;
import mxhx.manifest.MXHXManifestTools;
#end

class MXHXResolvers {
	#if macro
	private static final LANGUAGE_URI_BASIC_2024 = "https://ns.mxhx.dev/2024/basic";
	private static final LANGUAGE_URI_FULL_2024 = "https://ns.mxhx.dev/2024/mxhx";
	private static final LANGUAGE_MAPPINGS_2024 = [
		"Array" => "Array",
		"Bool" => "Bool",
		"Class" => "Class",
		"Date" => "Date",
		"EReg" => "EReg",
		"Float" => "Float",
		"Function" => "haxe.Constraints.Function",
		"Int" => "Int",
		"Object" => "Any",
		"String" => "String",
		"Struct" => "Dynamic",
		"UInt" => "UInt",
		"Xml" => "Xml",
	];

	private static final manifests:Map<String, Map<String, String>> = [
		LANGUAGE_URI_BASIC_2024 => LANGUAGE_MAPPINGS_2024,
		LANGUAGE_URI_FULL_2024 => LANGUAGE_MAPPINGS_2024,
	];

	/**
		Adds a custom mapping from a namespace URI to a list of components in
		the namespace.
	**/
	public static function registerMappings(uri:String, mappings:Map<String, String>):Void {
		manifests.set(uri, mappings);
	}

	/**
		Adds a custom mapping from a namespace URI to a list of components in
		the namespace using a manifest file.
	**/
	public static function registerManifestFile(uri:String, manifestFilePath:String):Void {
		try {
			var mappings = MXHXManifestTools.parseManifestFile(manifestFilePath);
			manifests.set(uri, mappings);
		} catch (e:String) {
			#if (haxe_ver >= 4.3) Context.reportError #else Context.error #end (e, Context.currentPos());
			return;
		} catch (e:Dynamic) {
			#if (haxe_ver >= 4.3) Context.reportError #else Context.error #end ('Unknown error parsing manifest file: ${manifestFilePath}',
				Context.currentPos());
			return;
		}
	}

	public static function getMappingsForUri(uri:String):Map<String, String> {
		var mappings = manifests.get(uri);
		if (mappings == null) {
			return null;
		}
		return mappings.copy();
	}

	public static function getMappings():Map<String, Map<String, String>> {
		return manifests.copy();
	}
	#end

	public static macro function emitMappingsForUri(uri:String):Expr {
		var mappings = manifests.get(uri);
		return macro $v{mappings};
	}

	public static macro function emitMappings():Expr {
		var exprs:Array<Expr> = [macro var mappings:Map<String, Map<String, String>> = []];
		for (uri => mappings in manifests) {
			exprs.push(macro var uriMappings:Map<String, String> = []);
			for (key => value in mappings) {
				exprs.push(macro uriMappings.set($v{key}, $v{value}));
			}
			exprs.push(macro mappings.set($v{uri}, uriMappings));
		}
		exprs.push(macro mappings);
		return macro $b{exprs};
	}
}
