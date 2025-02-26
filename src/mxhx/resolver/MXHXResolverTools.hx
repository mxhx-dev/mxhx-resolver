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

class MXHXResolverTools {
	public static function filePathAndPackToModule(filePath:String, pack:Array<String>):String {
		var index = filePath.lastIndexOf("/");
		for (i in 0...pack.length) {
			index = filePath.lastIndexOf("/", index - 1);
		}
		return StringTools.replace(filePath.substring(index + 1, filePath.length - 3), "/", ".");
	}

	public static function definitionToQname(definitionName:String, pack:Array<String>, moduleName:String, ?params:Array<String>):String {
		var qname = definitionName;
		if (pack.length > 0) {
			qname = pack.join(".") + "." + qname;
		}
		if (qname != moduleName && moduleName != "StdTypes") {
			qname = moduleName + "." + definitionName;
		}
		if (params != null && params.length > 0) {
			qname += "<";
			for (i in 0...params.length) {
				var param = params[i];
				if (i > 0) {
					qname += ",";
				}
				if (param == null) {
					qname += "%";
				} else {
					qname += param;
				}
			}
			qname += ">";
		}
		return qname;
	}
}
