package mxhx.internal.resolver;

import mxhx.resolver.IMXHXArgumentSymbol;
import mxhx.resolver.IMXHXTypeSymbol;

class MXHXArgumentSymbol implements IMXHXArgumentSymbol {
	public var name:String;
	public var type:IMXHXTypeSymbol;
	public var optional:Bool;

	public function new(name:String, type:IMXHXTypeSymbol, optional:Bool) {
		this.name = name;
		this.type = type;
		this.optional = optional;
	}
}
