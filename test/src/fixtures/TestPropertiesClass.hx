package fixtures;

import haxe.Constraints.Function;
import fixtures.ModuleWithClassThatHasDifferentName.ThisClassHasADifferentNameThanItsModule;

@:event("change")
class TestPropertiesClass implements ITestPropertiesInterface {
	public function new() {}

	public var any:Any;
	public var struct:Dynamic;
	public var boolean:Bool;
	public var ereg:EReg;
	public var float:Float;
	public var integer:Int;
	public var string:String;
	public var unsignedInteger:UInt;
	public var abstractEnumValue:TestPropertyAbstractEnum;
	public var enumValue:TestPropertyEnum;
	public var strictlyTyped:TestPropertiesClass;
	public var array:Array<String>;
	public var type:Class<Dynamic>;
	public var func:Function;
	public var funcTyped:() -> Void;
	public var complexEnum:TestComplexEnum;
	public var canBeNull:Null<Float>;
	public var date:Date;
	public var xml:Xml;
	public var abstractFrom:TestAbstractFrom;
	public var abstractFromModuleType:TestAbstractFromModuleType;
	public var classFromModuleWithDifferentName:ThisClassHasADifferentNameThanItsModule;
	public var strictInterface:ITestPropertiesInterface;

	// compilation will fail if Context.getType() is used with this one
	// needs a typedef for a class with @:generic, and not the class alone
	public var genericMeta:TestTypedefWithGenericMeta<String>;

	// for testing properties typed as functions
	public function testMethod():Void {}
}
