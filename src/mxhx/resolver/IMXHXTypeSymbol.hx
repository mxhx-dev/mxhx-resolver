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

import haxe.macro.Expr.MetadataEntry;

/**
	An MXHX symbol representing a Haxe type, such as a class or abstract.
**/
interface IMXHXTypeSymbol extends IMXHXSymbol {
	public var qname:String;
	public var module:String;
	public var pack:Array<String>;
	public var params:Array<IMXHXTypeSymbol>;
}
