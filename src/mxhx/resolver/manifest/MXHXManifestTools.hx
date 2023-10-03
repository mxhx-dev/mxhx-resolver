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

package mxhx.resolver.manifest;

class MXHXManifestTools {
	public static function parseManifest(manifestText:String):Map<String, String> {
		try {
			var xml = Xml.parse(manifestText);
			var mappings:Map<String, String> = [];
			for (componentXml in xml.firstElement().elementsNamed("component")) {
				var xmlName = componentXml.get("id");
				var qname = componentXml.get("class");
				mappings.set(xmlName, qname);
			}
			return mappings;
		} catch (e:Dynamic) {
			throw "Failed to parse manifest. Invalid content.";
		}
	}

	#if (sys || hxnodejs)
	public static function parseManifestFile(filePath:String):Map<String, String> {
		if (!sys.FileSystem.exists(filePath)) {
			throw 'Manifest file not found: ${filePath}';
		}
		var manifestText:String = null;
		try {
			manifestText = sys.io.File.getContent(filePath);
		} catch (e:Dynamic) {
			throw "Failed to parse manifest. Cannot read file: " + filePath;
		}
		return parseManifest(manifestText);
	}
	#end
}
