package mxhx.internal.resolver;

import mxhx.resolver.IMXHXTypeSymbol;
import mxhx.resolver.IMXHXEventSymbol;
import mxhx.resolver.IMXHXFieldSymbol;
import mxhx.resolver.IMXHXInterfaceSymbol;
import mxhx.resolver.IMXHXClassSymbol;

class MXHXClassSymbol extends MXHXTypeSymbol implements IMXHXClassSymbol {
	public var superClass:IMXHXClassSymbol;
	public var interfaces:Array<IMXHXInterfaceSymbol>;
	public var fields:Array<IMXHXFieldSymbol>;
	public var events:Array<IMXHXEventSymbol>;
	public var defaultProperty:String;

	public function new(name:String, ?pack:Array<String>, ?params:Array<IMXHXTypeSymbol>, ?superClass:IMXHXClassSymbol,
			?interfaces:Array<IMXHXInterfaceSymbol>, ?fields:Array<IMXHXFieldSymbol>, ?events:Array<IMXHXEventSymbol>, ?defaultProperty:String) {
		super(name, pack, params);
		this.superClass = superClass;
		this.interfaces = interfaces != null ? interfaces : [];
		this.fields = fields != null ? fields : [];
		this.events = events != null ? events : [];
		this.defaultProperty = defaultProperty;
	}
}
