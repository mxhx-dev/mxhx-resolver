package mxhx.internal.resolver;

import mxhx.resolver.IMXHXClassSymbol;
import mxhx.resolver.IMXHXEventSymbol;

class MXHXEventSymbol implements IMXHXEventSymbol {
	public var name:String;
	public var type:IMXHXClassSymbol;

	public function new(name:String, type:IMXHXClassSymbol) {
		this.name = name;
		this.type = type;
	}
}
