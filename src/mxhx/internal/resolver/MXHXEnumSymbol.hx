package mxhx.internal.resolver;

import mxhx.resolver.IMXHXEnumFieldSymbol;
import mxhx.resolver.IMXHXTypeSymbol;
import mxhx.resolver.IMXHXEnumSymbol;

class MXHXEnumSymbol extends MXHXTypeSymbol implements IMXHXEnumSymbol {
	public var fields:Array<IMXHXEnumFieldSymbol>;

	public function new(name:String, ?pack:Array<String>, ?params:Array<IMXHXTypeSymbol>, ?fields:Array<IMXHXEnumFieldSymbol>) {
		super(name, pack, params);
		this.fields = fields != null ? fields : [];
	}
}
