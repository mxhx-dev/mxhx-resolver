class TestClass {
	public function new() {}

	public var component:Class<Dynamic>;
	public var testVarStr:String;
	public var testVarFloat:Float;
	public var testVarAny:Any;
	public var testVarBool:Bool;
	public var testVarInt:Int;
	public var testVarUInt:UInt;
	public var testVarArray:Array<Float>;
	public var testVarArrayArray:Array<Array<Int>>;

	public function testMethod():Void {
		trace("called testMethod");
	}
}
