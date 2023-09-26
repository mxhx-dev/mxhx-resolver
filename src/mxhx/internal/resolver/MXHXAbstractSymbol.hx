package mxhx.internal.resolver;

import mxhx.resolver.IMXHXTypeSymbol;
import mxhx.resolver.IMXHXAbstractSymbol;

class MXHXAbstractSymbol extends MXHXTypeSymbol implements IMXHXAbstractSymbol {
	public var from:Array<IMXHXTypeSymbol>;

	public function new(name:String, ?pack:Array<String>, ?params:Array<IMXHXTypeSymbol>, ?from:Array<IMXHXTypeSymbol>) {
		super(name, pack, params);
		this.from = from != null ? from : [];
	}
}
