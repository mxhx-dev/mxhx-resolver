package mxhx.internal.resolver;

import mxhx.resolver.IMXHXTypeSymbol;
import mxhx.resolver.IMXHXEventSymbol;
import mxhx.resolver.IMXHXFieldSymbol;
import mxhx.resolver.IMXHXInterfaceSymbol;

class MXHXInterfaceSymbol extends MXHXTypeSymbol implements IMXHXInterfaceSymbol {
	public var interfaces:Array<IMXHXInterfaceSymbol>;
	public var fields:Array<IMXHXFieldSymbol>;

	public function new(name:String, ?pack:Array<String>, ?params:Array<IMXHXTypeSymbol>, ?interfaces:Array<IMXHXInterfaceSymbol>,
			?fields:Array<IMXHXFieldSymbol>) {
		super(name, pack, params);
		this.interfaces = interfaces != null ? interfaces : [];
		this.fields = fields != null ? fields : [];
	}
}
