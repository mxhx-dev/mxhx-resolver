package mxhx.internal.resolver;

import mxhx.resolver.IMXHXTypeSymbol;
import mxhx.resolver.IMXHXFieldSymbol;

class MXHXFieldSymbol implements IMXHXFieldSymbol {
	public var name:String;
	public var type:IMXHXTypeSymbol;
	public var isMethod:Bool;

	public function new(name:String, ?type:IMXHXTypeSymbol, isMethod:Bool = false) {
		this.name = name;
		this.type = type;
		this.isMethod = isMethod;
	}
}
