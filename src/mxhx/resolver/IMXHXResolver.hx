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

import mxhx.manifest.MXHXManifestEntry;
import mxhx.symbols.IMXHXFieldSymbol;
import mxhx.symbols.IMXHXSymbol;
import mxhx.symbols.IMXHXTypeSymbol;

/**
	An MXHX symbol resolver.
**/
interface IMXHXResolver {
	public function registerManifest(uri:String, mappings:Map<String, MXHXManifestEntry>):Void;
	public function resolveTag(tagData:IMXHXTagData):IMXHXSymbol;
	public function resolveAttribute(attributeData:IMXHXTagAttributeData):IMXHXSymbol;
	public function resolveTagField(tagData:IMXHXTagData, fieldName:String):IMXHXFieldSymbol;
	public function resolveQname(qname:String):IMXHXTypeSymbol;
	public function getTagNamesForQname(qname:String):Map<String, String>;
	public function getParamsForQname(tagName:String):Array<String>;
	public function getTypes():Array<IMXHXTypeSymbol>;
}
