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
	An MXHX symbol representing a Haxe class.
**/
interface IMXHXClassSymbol extends IMXHXTypeSymbol {
	/**
		The super class that this class extends, or null.
	**/
	public var superClass:IMXHXClassSymbol;

	/**
		A collection of fields declared on the class.
	**/
	public var fields:Array<IMXHXFieldSymbol>;

	/**
		A collection of events dispatched by the class.
	**/
	public var events:Array<IMXHXEventSymbol>;

	/**
		The default property of the class that doesn't need an explicit child
		tag in MXHX.
	**/
	public var defaultProperty:String;
}
