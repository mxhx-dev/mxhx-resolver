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

/**
	Any symbol represented in MXHX.
**/
interface IMXHXSymbol {
	/**
		The base name of the symbol, without the package (if applicable).
	**/
	public var name:String;

	/**
		The documentation associated with the symbol. Resolvers are not required
		to populate this field, so it may be null.
	**/
	public var doc:Null<String>;

	/**
		The path to the file containing the symbol.
	**/
	public var file:String;

	/**
		The position within the file containing the symbol.
	**/
	public var offsets:{start:Int, end:Int};
}
