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

package mxhx.resolver;

import haxe.macro.Expr;
#if macro
import haxe.macro.Context;
import mxhx.manifest.MXHXManifestEntry;
import mxhx.manifest.MXHXManifestTools;
#end

class MXHXResolvers {
	#if macro
	private static final LANGUAGE_URI_BASIC_2024 = "https://ns.mxhx.dev/2024/basic";
	private static final LANGUAGE_URI_FULL_2024 = "https://ns.mxhx.dev/2024/mxhx";
	private static final LANGUAGE_MAPPINGS_2024 = [
		"Array" => new MXHXManifestEntry("Array", null, ["type"]),
		"Bool" => new MXHXManifestEntry("Bool"),
		"Class" => new MXHXManifestEntry("Class"),
		"Date" => new MXHXManifestEntry("Date"),
		"EReg" => new MXHXManifestEntry("EReg"),
		"Float" => new MXHXManifestEntry("Float"),
		"Function" => new MXHXManifestEntry("Function", "haxe.Constraints.Function"),
		"Int" => new MXHXManifestEntry("Int"),
		"Object" => new MXHXManifestEntry("Any"),
		"String" => new MXHXManifestEntry("String"),
		"Struct" => new MXHXManifestEntry("Dynamic"),
		"UInt" => new MXHXManifestEntry("UInt"),
		"Xml" => new MXHXManifestEntry("Xml"),
	];

	private static final manifests:Map<String, Map<String, MXHXManifestEntry>> = [
		LANGUAGE_URI_BASIC_2024 => LANGUAGE_MAPPINGS_2024,
		LANGUAGE_URI_FULL_2024 => LANGUAGE_MAPPINGS_2024,
	];

	/**
		Adds a custom mapping from a namespace URI to a list of components in
		the namespace.
	**/
	public static function registerMappings(uri:String, mappings:Map<String, MXHXManifestEntry>):Void {
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

	public static function getMappingsForUri(uri:String):Map<String, MXHXManifestEntry> {
		var mappings = manifests.get(uri);
		if (mappings == null) {
			return null;
		}
		return mappings.copy();
	}

	public static function getMappings():Map<String, Map<String, MXHXManifestEntry>> {
		return manifests.copy();
	}
	#end

	public static macro function emitMappingsForUri(uri:String):Expr {
		var mappings = manifests.get(uri);
		return macro $v{mappings};
	}

	public static macro function emitMappings():Expr {
		var exprs:Array<Expr> = [
			macro var mappings:Map<String, Map<String, mxhx.manifest.MXHXManifestEntry>> = []
		];
		for (uri => mappings in manifests) {
			exprs.push(macro var uriMappings:Map<String, mxhx.manifest.MXHXManifestEntry> = []);
			for (id => manifestEntry in mappings) {
				if (manifestEntry.params != null) {
					exprs.push(macro uriMappings.set($v{id},
						new mxhx.manifest.MXHXManifestEntry($v{manifestEntry.id}, $v{manifestEntry.qname}, $v{manifestEntry.params})));
				} else if (manifestEntry.id != manifestEntry.qname) {
					exprs.push(macro uriMappings.set($v{id}, new mxhx.manifest.MXHXManifestEntry($v{manifestEntry.id}, $v{manifestEntry.qname})));
				} else {
					exprs.push(macro uriMappings.set($v{id}, new mxhx.manifest.MXHXManifestEntry($v{manifestEntry.id})));
				}
			}
			exprs.push(macro mappings.set($v{uri}, uriMappings));
		}
		exprs.push(macro mappings);
		return macro $b{exprs};
	}
}
