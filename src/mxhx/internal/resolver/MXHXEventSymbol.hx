package mxhx.internal.resolver;

import haxe.macro.Expr.MetadataEntry;
import mxhx.resolver.IMXHXClassSymbol;
import mxhx.resolver.IMXHXEventSymbol;

class MXHXEventSymbol implements IMXHXEventSymbol {
	public var name:String;
	public var doc:Null<String>;
	public var file:String;
	public var offsets:{start:Int, end:Int};
	public var type:IMXHXClassSymbol;
	public var meta:Array<MetadataEntry>;

	public function new(name:String, type:IMXHXClassSymbol) {
		this.name = name;
		this.type = type;
	}
}
