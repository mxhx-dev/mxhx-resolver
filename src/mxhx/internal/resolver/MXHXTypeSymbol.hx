package mxhx.internal.resolver;

import haxe.macro.Expr.MetadataEntry;
import mxhx.resolver.IMXHXTypeSymbol;

class MXHXTypeSymbol implements IMXHXTypeSymbol {
	public var name:String;
	public var doc:Null<String>;
	public var file:String;
	public var offsets:{start:Int, end:Int};
	public var pack:Array<String>;
	public var qname:String;
	public var module:String;
	public var params:Array<IMXHXTypeSymbol>;
	public var meta:Array<MetadataEntry>;

	public function new(name:String, ?pack:Array<String>, ?params:Array<IMXHXTypeSymbol>) {
		this.name = name;
		this.pack = pack != null ? pack : [];
		this.params = params != null ? params : [];
	}
}
