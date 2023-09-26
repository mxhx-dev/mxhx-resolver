package mxhx.internal.resolver;

import mxhx.resolver.IMXHXArgumentSymbol;
import mxhx.resolver.IMXHXEnumSymbol;
import mxhx.resolver.IMXHXEnumFieldSymbol;

class MXHXEnumFieldSymbol implements IMXHXEnumFieldSymbol {
	public var name:String;
	public var parent:IMXHXEnumSymbol;
	public var args:Array<IMXHXArgumentSymbol>;

	public function new(name:String, ?parent:IMXHXEnumSymbol, ?args:Array<IMXHXArgumentSymbol>) {
		this.name = name;
		this.parent = parent;
		this.args = args != null ? args : [];
	}
}
