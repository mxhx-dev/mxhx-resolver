package mxhx.internal.resolver;

import mxhx.resolver.IMXHXTypeSymbol;

class MXHXTypeSymbol implements IMXHXTypeSymbol {
	public var name:String;
	public var pack:Array<String>;
	public var qname:String;
	public var module:String;
	public var params:Array<IMXHXTypeSymbol>;

	public function new(name:String, ?pack:Array<String>, ?params:Array<IMXHXTypeSymbol>) {
		this.name = name;
		this.pack = pack != null ? pack : [];
		this.params = params != null ? params : [];
	}
}
