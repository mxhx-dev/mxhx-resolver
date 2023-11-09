package mxhx.internal.resolver;

import mxhx.resolver.IMXHXTypeSymbol;
import mxhx.resolver.IMXHXFieldSymbol;

class MXHXFieldSymbol implements IMXHXFieldSymbol {
	public var name:String;
	public var doc:Null<String>;
	public var file:String;
	public var offsets:{start:Int, end:Int};
	public var type:IMXHXTypeSymbol;
	public var isMethod:Bool;
	public var isPublic:Bool;

	public function new(name:String, ?type:IMXHXTypeSymbol, isMethod:Bool = false, isPublic:Bool = true) {
		this.name = name;
		this.type = type;
		this.isMethod = isMethod;
		this.isPublic = isPublic;
	}
}
