package mxhx.resolver.macro;

import mxhx.IMXHXTagData;
import mxhx.parser.MXHXParser;
import mxhx.resolver.IMXHXClassSymbol;
import mxhx.resolver.IMXHXFieldSymbol;
import mxhx.resolver.IMXHXInterfaceSymbol;
import mxhx.resolver.IMXHXTypeSymbol;
import mxhx.resolver.macro.MXHXMacroResolver;
import utest.Test;
#if !macro
import utest.Assert;
#end

class MXHXMacroResolverTest extends Test {
	#if !macro
	public function testResolveAny():Void {
		var resolved = resolveQname("Any");
		Assert.notNull(resolved);
		Assert.equals("Any", resolved);
	}

	public function testResolveArray():Void {
		var resolved = resolveQname("Array");
		Assert.notNull(resolved);
		Assert.equals("Array", resolved);
	}

	public function testResolveBool():Void {
		var resolved = resolveQname("Bool");
		Assert.notNull(resolved);
		Assert.equals("Bool", resolved);
	}

	public function testResolveStdTypesBool():Void {
		var resolved = resolveQname("StdTypes.Bool");
		Assert.notNull(resolved);
		Assert.equals("Bool", resolved);
	}

	public function testResolveDynamic():Void {
		var resolved = resolveQname("Dynamic");
		Assert.notNull(resolved);
		Assert.equals("Dynamic", resolved);
	}

	public function testResolveEReg():Void {
		var resolved = resolveQname("EReg");
		Assert.notNull(resolved);
		Assert.equals("EReg", resolved);
	}

	public function testResolveFloat():Void {
		var resolved = resolveQname("Float");
		Assert.notNull(resolved);
		Assert.equals("Float", resolved);
	}

	public function testResolveStdTypesFloat():Void {
		var resolved = resolveQname("StdTypes.Float");
		Assert.notNull(resolved);
		Assert.equals("Float", resolved);
	}

	public function testResolveInt():Void {
		var resolved = resolveQname("Int");
		Assert.notNull(resolved);
		Assert.equals("Int", resolved);
	}

	public function testResolveStdTypesInt():Void {
		var resolved = resolveQname("StdTypes.Int");
		Assert.notNull(resolved);
		Assert.equals("Int", resolved);
	}

	public function testResolveString():Void {
		var resolved = resolveQname("String");
		Assert.notNull(resolved);
		Assert.equals("String", resolved);
	}

	public function testResolveUInt():Void {
		var resolved = resolveQname("UInt");
		Assert.notNull(resolved);
		Assert.equals("UInt", resolved);
	}

	public function testResolveQnameFromLocalClass():Void {
		var resolved = resolveQname("fixtures.TestPropertiesClass");
		Assert.notNull(resolved);
		Assert.equals("fixtures.TestPropertiesClass", resolved);
	}

	public function testResolveQnameFromLocalInterface():Void {
		var resolved = resolveQname("fixtures.ITestPropertiesInterface");
		Assert.notNull(resolved);
		Assert.equals("fixtures.ITestPropertiesInterface", resolved);
	}

	public function testResolveAnyField():Void {
		var resolved = resolveQnameFieldType("fixtures.TestPropertiesClass", "any");
		Assert.notNull(resolved);
		Assert.equals("Any", resolved);
	}

	public function testResolveArrayField():Void {
		var resolved = resolveQnameFieldType("fixtures.TestPropertiesClass", "array");
		Assert.notNull(resolved);
		Assert.equals("Array<String>", resolved);
	}

	public function testResolveBoolField():Void {
		var resolved = resolveQnameFieldType("fixtures.TestPropertiesClass", "boolean");
		Assert.notNull(resolved);
		Assert.equals("Bool", resolved);
	}

	public function testResolveClassField():Void {
		var resolved = resolveQnameFieldType("fixtures.TestPropertiesClass", "type");
		Assert.notNull(resolved);
		// TODO: fix the % that should be used only internally
		Assert.equals("Class<Dynamic<%>>", resolved);
	}

	public function testResolveDateField():Void {
		var resolved = resolveQnameFieldType("fixtures.TestPropertiesClass", "date");
		Assert.notNull(resolved);
		Assert.equals("Date", resolved);
	}

	public function testResolveDynamicField():Void {
		var resolved = resolveQnameFieldType("fixtures.TestPropertiesClass", "struct");
		Assert.notNull(resolved);
		// TODO: fix the % that should be used only internally
		Assert.equals("Dynamic<%>", resolved);
	}

	public function testResolveERegField():Void {
		var resolved = resolveQnameFieldType("fixtures.TestPropertiesClass", "ereg");
		Assert.notNull(resolved);
		Assert.equals("EReg", resolved);
	}

	public function testResolveFloatField():Void {
		var resolved = resolveQnameFieldType("fixtures.TestPropertiesClass", "float");
		Assert.equals("Float", resolved);
	}

	public function testResolveFunctionConstraintField():Void {
		var resolved = resolveQnameFieldType("fixtures.TestPropertiesClass", "func");
		Assert.equals("haxe.Constraints.Function", resolved);
	}

	public function testResolveFunctionSignatureField():Void {
		var resolved = resolveQnameFieldType("fixtures.TestPropertiesClass", "funcTyped");
		Assert.equals("haxe.Constraints.Function", resolved);
	}

	public function testResolveIntField():Void {
		var resolved = resolveQnameFieldType("fixtures.TestPropertiesClass", "integer");
		Assert.notNull(resolved);
		Assert.equals("Int", resolved);
	}

	public function testResolveStringField():Void {
		var resolved = resolveQnameFieldType("fixtures.TestPropertiesClass", "string");
		Assert.notNull(resolved);
		Assert.equals("String", resolved);
	}

	public function testResolveUIntField():Void {
		var resolved = resolveQnameFieldType("fixtures.TestPropertiesClass", "unsignedInteger");
		Assert.notNull(resolved);
		Assert.equals("UInt", resolved);
	}

	public function testResolveXmlField():Void {
		var resolved = resolveQnameFieldType("fixtures.TestPropertiesClass", "xml");
		Assert.notNull(resolved);
		Assert.equals("Xml", resolved);
	}

	public function testResolveNullField():Void {
		var resolved = resolveQnameFieldType("fixtures.TestPropertiesClass", "canBeNull");
		Assert.notNull(resolved);
		Assert.equals("Null<Float>", resolved);
	}

	public function testResolveStrictlyTypedField():Void {
		var resolved = resolveQnameFieldType("fixtures.TestPropertiesClass", "strictlyTyped");
		Assert.notNull(resolved);
		Assert.equals("fixtures.TestPropertiesClass", resolved);
	}

	public function testResolveStrictlyTypedInterfaceField():Void {
		var resolved = resolveQnameFieldType("fixtures.TestPropertiesClass", "strictInterface");
		Assert.notNull(resolved);
		Assert.equals("fixtures.ITestPropertiesInterface", resolved);
	}

	public function testResolveAbstractEnumValueField():Void {
		var resolved = resolveQnameFieldType("fixtures.TestPropertiesClass", "abstractEnumValue");
		Assert.notNull(resolved);
		Assert.equals("fixtures.TestPropertyAbstractEnum", resolved);
	}

	public function testResolveEnumValueField():Void {
		var resolved = resolveQnameFieldType("fixtures.TestPropertiesClass", "enumValue");
		Assert.notNull(resolved);
		Assert.equals("fixtures.TestPropertyEnum", resolved);
	}

	public function testResolveClassFromModuleWithDifferentName():Void {
		var resolved = resolveQnameFieldType("fixtures.TestPropertiesClass", "classFromModuleWithDifferentName");
		Assert.notNull(resolved);
		Assert.equals("fixtures.ModuleWithClassThatHasDifferentName.ThisClassHasADifferentNameThanItsModule", resolved);
	}

	public function testResolveFieldWithTypeParameter():Void {
		var resolved = resolveQnameFieldType("fixtures.ArrayCollection", "array");
		Assert.notNull(resolved);
		// TODO: fix the % that should be used only internally
		Assert.equals("Array<%>", resolved);
	}

	// ----- resolve tag type

	public function testResolveRootTag():Void {
		var resolved = resolveTagType('
			<tests:TestClass1 xmlns:tests="https://ns.mxhx.dev/2024/tests"/>
		', 15);
		Assert.notNull(resolved);
		Assert.equals("fixtures.TestClass1", resolved);
	}

	public function testResolveRootTagObject():Void {
		var resolved = resolveTagType('
			<mx:Object xmlns:mx="https://ns.mxhx.dev/2024/basic"/>
		', 10);
		Assert.notNull(resolved);
		Assert.equals("Any", resolved);
	}

	public function testResolveDeclarationsArray():Void {
		var resolved = resolveTagType('
			<tests:TestClass1 xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<mx:Declarations>
					<mx:Array type="Float"/>
				</mx:Declarations>
			</tests:TestClass1>
		', 142);
		Assert.notNull(resolved);
		Assert.equals("Array<Float>", resolved);
	}

	public function testResolveDeclarationsBool():Void {
		var resolved = resolveTagType('
			<tests:TestClass1 xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<mx:Declarations>
					<mx:Bool/>
				</mx:Declarations>
			</tests:TestClass1>
		', 142);
		Assert.notNull(resolved);
		Assert.equals("Bool", resolved);
	}

	public function testResolveDeclarationsDate():Void {
		var resolved = resolveTagType('
			<tests:TestClass1 xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<mx:Declarations>
					<mx:Date/>
				</mx:Declarations>
			</tests:TestClass1>
		', 142);
		Assert.notNull(resolved);
		Assert.equals("Date", resolved);
	}

	public function testResolveDeclarationsEReg():Void {
		var resolved = resolveTagType('
			<tests:TestClass1 xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<mx:Declarations>
					<mx:EReg/>
				</mx:Declarations>
			</tests:TestClass1>
		', 142);
		Assert.notNull(resolved);
		Assert.equals("EReg", resolved);
	}

	public function testResolveDeclarationsFloat():Void {
		var resolved = resolveTagType('
			<tests:TestClass1 xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<mx:Declarations>
					<mx:Float/>
				</mx:Declarations>
			</tests:TestClass1>
		', 142);
		Assert.notNull(resolved);
		Assert.equals("Float", resolved);
	}

	public function testResolveDeclarationsFunction():Void {
		var resolved = resolveTagType('
			<tests:TestClass1 xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<mx:Declarations>
					<mx:Function/>
				</mx:Declarations>
			</tests:TestClass1>
		', 142);
		Assert.notNull(resolved);
		Assert.equals("haxe.Constraints.Function", resolved);
	}

	public function testResolveDeclarationsInt():Void {
		var resolved = resolveTagType('
			<tests:TestClass1 xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<mx:Declarations>
					<mx:Int/>
				</mx:Declarations>
			</tests:TestClass1>
		', 142);
		Assert.notNull(resolved);
		Assert.equals("Int", resolved);
	}

	public function testResolveDeclarationsString():Void {
		var resolved = resolveTagType('
			<tests:TestClass1 xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<mx:Declarations>
					<mx:String/>
				</mx:Declarations>
			</tests:TestClass1>
		', 142);
		Assert.notNull(resolved);
		Assert.equals("String", resolved);
	}

	public function testResolveDeclarationsStruct():Void {
		var resolved = resolveTagType('
			<tests:TestClass1 xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<mx:Declarations>
					<mx:Struct/>
				</mx:Declarations>
			</tests:TestClass1>
		', 142);
		Assert.notNull(resolved);
		// TODO: fix the % that should be used only internally
		Assert.equals("Dynamic<%>", resolved);
	}

	public function testResolveDeclarationsUInt():Void {
		var resolved = resolveTagType('
			<tests:TestClass1 xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<mx:Declarations>
					<mx:UInt/>
				</mx:Declarations>
			</tests:TestClass1>
		', 142);
		Assert.notNull(resolved);
		Assert.equals("UInt", resolved);
	}

	public function testResolveDeclarationsXml():Void {
		var resolved = resolveTagType('
			<tests:TestClass1 xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<mx:Declarations>
					<mx:Xml/>
				</mx:Declarations>
			</tests:TestClass1>
		', 142);
		Assert.notNull(resolved);
		Assert.equals("Xml", resolved);
	}

	// ---- resolve field type

	public function testResolveFieldTypeAny():Void {
		var resolvedFieldType = resolveTagType('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:any>
					<mx:Float/>
				</tests:any>
			</tests:TestPropertiesClass>
		', 132);
		Assert.notNull(resolvedFieldType);
		Assert.equals("Any", resolvedFieldType);
	}

	public function testResolveFieldTypeArray():Void {
		var resolvedFieldType = resolveTagType('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:array>
					<mx:Array/>
				</tests:array>
			</tests:TestPropertiesClass>
		', 132);
		Assert.notNull(resolvedFieldType);
		Assert.equals("Array<String>", resolvedFieldType);
	}

	public function testResolveFieldTypeBool():Void {
		var resolvedFieldType = resolveTagType('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:boolean>
					<mx:Bool/>
				</tests:boolean>
			</tests:TestPropertiesClass>
		', 132);
		Assert.notNull(resolvedFieldType);
		Assert.equals("Bool", resolvedFieldType);
	}

	public function testResolveFieldTypeClass():Void {
		var resolvedFieldType = resolveTagType('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:type>
					<mx:Class>Float</mx:Class>
				</tests:type>
			</tests:TestPropertiesClass>
		', 132);
		Assert.notNull(resolvedFieldType);
		// TODO: fix the % that should be used only internally
		Assert.equals("Class<Dynamic<%>>", resolvedFieldType);
	}

	public function testResolveFieldTypeDate():Void {
		var resolvedFieldType = resolveTagType('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:date>
					<mx:Date/>
				</tests:date>
			</tests:TestPropertiesClass>
		', 132);
		Assert.notNull(resolvedFieldType);
		Assert.equals("Date", resolvedFieldType);
	}

	public function testResolveFieldTypeDynamic():Void {
		var resolvedFieldType = resolveTagType('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:struct>
					<mx:Struct/>
				</tests:struct>
			</tests:TestPropertiesClass>
		', 132);
		Assert.notNull(resolvedFieldType);
		// TODO: fix the % that should be used only internally
		Assert.equals("Dynamic<%>", resolvedFieldType);
	}

	public function testResolveFieldTypeEReg():Void {
		var resolvedFieldType = resolveTagType('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:ereg>
					<mx:EReg/>
				</tests:ereg>
			</tests:TestPropertiesClass>
		', 132);
		Assert.notNull(resolvedFieldType);
		Assert.equals("EReg", resolvedFieldType);
	}

	public function testResolveFieldTypeFloat():Void {
		var resolvedFieldType = resolveTagType('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:float>
					<mx:Float/>
				</tests:float>
			</tests:TestPropertiesClass>
		', 132);
		Assert.notNull(resolvedFieldType);
		Assert.equals("Float", resolvedFieldType);
	}

	public function testResolveFieldTypeFunction():Void {
		var resolvedFieldType = resolveTagType('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:func>
					<mx:Function/>
				</tests:func>
			</tests:TestPropertiesClass>
		', 132);
		Assert.notNull(resolvedFieldType);
		Assert.equals("haxe.Constraints.Function", resolvedFieldType);
	}

	public function testResolveFieldTypeFunctionSignature():Void {
		var resolvedFieldType = resolveTagType('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:funcTyped>
					<mx:Function/>
				</tests:funcTyped>
			</tests:TestPropertiesClass>
		', 132);
		Assert.notNull(resolvedFieldType);
		Assert.equals("haxe.Constraints.Function", resolvedFieldType);
	}

	public function testResolveFieldTypeInt():Void {
		var resolvedFieldType = resolveTagType('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:integer>
					<mx:Int/>
				</tests:integer>
			</tests:TestPropertiesClass>
		', 132);
		Assert.notNull(resolvedFieldType);
		Assert.equals("Int", resolvedFieldType);
	}

	public function testResolveFieldTypeString():Void {
		var resolvedFieldType = resolveTagType('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:string>
					<mx:String/>
				</tests:string>
			</tests:TestPropertiesClass>
		', 132);
		Assert.notNull(resolvedFieldType);
		Assert.equals("String", resolvedFieldType);
	}

	public function testResolveFieldTypeStruct():Void {
		var resolvedFieldType = resolveTagType('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:struct>
					<mx:Struct/>
				</tests:struct>
			</tests:TestPropertiesClass>
		', 132);
		Assert.notNull(resolvedFieldType);
		// TODO: fix the % that should be used only internally
		Assert.equals("Dynamic<%>", resolvedFieldType);
	}

	public function testResolveFieldTypeUInt():Void {
		var resolvedFieldType = resolveTagType('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:unsignedInteger>
					<mx:UInt/>
				</tests:unsignedInteger>
			</tests:TestPropertiesClass>
		', 132);
		Assert.notNull(resolvedFieldType);
		Assert.equals("UInt", resolvedFieldType);
	}

	public function testResolveFieldTypeXml():Void {
		var resolvedFieldType = resolveTagType('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:xml>
					<mx:Xml/>
				</tests:xml>
			</tests:TestPropertiesClass>
		', 132);
		Assert.notNull(resolvedFieldType);
		Assert.equals("Xml", resolvedFieldType);
	}

	public function testResolveFieldTypeAbstractEnumValue():Void {
		var resolvedFieldType = resolveTagType('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:abstractEnumValue>
					<tests:TestPropertyAbstractEnum/>
				</tests:abstractEnumValue>
			</tests:TestPropertiesClass>
		', 132);
		Assert.notNull(resolvedFieldType);
		Assert.equals("fixtures.TestPropertyAbstractEnum", resolvedFieldType);
	}

	public function testResolveFieldTypeEnumValue():Void {
		var resolvedFieldType = resolveTagType('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:enumValue>
					<tests:TestPropertyEnum/>
				</tests:enumValue>
			</tests:TestPropertiesClass>
		', 132);
		Assert.notNull(resolvedFieldType);
		Assert.equals("fixtures.TestPropertyEnum", resolvedFieldType);
	}

	public function testResolveFieldTypeNull():Void {
		var resolvedFieldType = resolveTagType('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:canBeNull>
					<tests:Float/>
				</tests:canBeNull>
			</tests:TestPropertiesClass>
		', 132);
		Assert.notNull(resolvedFieldType);
		Assert.equals("Null<Float>", resolvedFieldType);
	}

	public function testResolveFieldTypeStrict():Void {
		var resolvedFieldType = resolveTagType('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:strictlyTyped>
					<tests:TestPropertiesClass/>
				</tests:strictlyTyped>
			</tests:TestPropertiesClass>
		', 132);
		Assert.notNull(resolvedFieldType);
		Assert.equals("fixtures.TestPropertiesClass", resolvedFieldType);
	}

	public function testResolveFieldTypeStrictInterface():Void {
		var resolvedFieldType = resolveTagType('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:strictInterface>
					<tests:TestPropertiesClass/>
				</tests:strictInterface>
			</tests:TestPropertiesClass>
		', 132);
		Assert.notNull(resolvedFieldType);
		Assert.equals("fixtures.ITestPropertiesInterface", resolvedFieldType);
	}

	// ---- resolve field value type

	public function testResolveFieldValueTypeAny():Void {
		var resolvedFieldType = resolveTagType('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:any>
					<mx:Float/>
				</tests:any>
			</tests:TestPropertiesClass>
		', 146);
		Assert.notNull(resolvedFieldType);
		// the field is typed as Any, but the value is more specific
		Assert.equals("Float", resolvedFieldType);
	}

	public function testResolveFieldValueTypeArray():Void {
		var resolvedFieldType = resolveTagType('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:array>
					<mx:Array type="String"/>
				</tests:array>
			</tests:TestPropertiesClass>
		', 148);
		Assert.notNull(resolvedFieldType);
		Assert.equals("Array<String>", resolvedFieldType);
	}

	public function testResolveFieldValueTypeBool():Void {
		var resolvedFieldType = resolveTagType('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:boolean>
					<mx:Bool/>
				</tests:boolean>
			</tests:TestPropertiesClass>
		', 150);
		Assert.notNull(resolvedFieldType);
		Assert.equals("Bool", resolvedFieldType);
	}

	public function testResolveFieldValueTypeClass():Void {
		var resolvedFieldType = resolveTagType('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:type>
					<mx:Class>Float</mx:Class>
				</tests:type>
			</tests:TestPropertiesClass>
		', 147);
		Assert.notNull(resolvedFieldType);
		// TODO: fix the % that should be used only internally
		Assert.equals("Class<%>", resolvedFieldType);
	}

	public function testResolveFieldValueTypeDate():Void {
		var resolvedFieldType = resolveTagType('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:date>
					<mx:Date/>
				</tests:date>
			</tests:TestPropertiesClass>
		', 147);
		Assert.notNull(resolvedFieldType);
		Assert.equals("Date", resolvedFieldType);
	}

	public function testResolveFieldValueTypeDynamic():Void {
		var resolvedFieldType = resolveTagType('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:struct>
					<mx:Struct/>
				</tests:struct>
			</tests:TestPropertiesClass>
		', 149);
		Assert.notNull(resolvedFieldType);
		// TODO: fix the % that should be used only internally
		Assert.equals("Dynamic<%>", resolvedFieldType);
	}

	public function testResolveFieldValueTypeEReg():Void {
		var resolvedFieldType = resolveTagType('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:ereg>
					<mx:EReg/>
				</tests:ereg>
			</tests:TestPropertiesClass>
		', 147);
		Assert.notNull(resolvedFieldType);
		Assert.equals("EReg", resolvedFieldType);
	}

	public function testResolveFieldValueTypeFloat():Void {
		var resolvedFieldType = resolveTagType('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:float>
					<mx:Float/>
				</tests:float>
			</tests:TestPropertiesClass>
		', 148);
		Assert.notNull(resolvedFieldType);
		Assert.equals("Float", resolvedFieldType);
	}

	public function testResolveFieldValueTypeFunction():Void {
		var resolvedFieldType = resolveTagType('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:func>
					<mx:Function/>
				</tests:func>
			</tests:TestPropertiesClass>
		', 147);
		Assert.notNull(resolvedFieldType);
		Assert.equals("haxe.Constraints.Function", resolvedFieldType);
	}

	public function testResolveFieldValueTypeFunctionSignature():Void {
		var resolvedFieldType = resolveTagType('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:funcTyped>
					<mx:Function/>
				</tests:funcTyped>
			</tests:TestPropertiesClass>
		', 152);
		Assert.notNull(resolvedFieldType);
		Assert.equals("haxe.Constraints.Function", resolvedFieldType);
	}

	public function testResolveFieldValueTypeInt():Void {
		var resolvedFieldType = resolveTagType('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:integer>
					<mx:Int/>
				</tests:integer>
			</tests:TestPropertiesClass>
		', 150);
		Assert.notNull(resolvedFieldType);
		Assert.equals("Int", resolvedFieldType);
	}

	public function testResolveFieldValueTypeString():Void {
		var resolvedFieldType = resolveTagType('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:string>
					<mx:String/>
				</tests:string>
			</tests:TestPropertiesClass>
		', 149);
		Assert.notNull(resolvedFieldType);
		Assert.equals("String", resolvedFieldType);
	}

	public function testResolveFieldValueTypeStruct():Void {
		var resolvedFieldType = resolveTagType('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:struct>
					<mx:Struct/>
				</tests:struct>
			</tests:TestPropertiesClass>
		', 149);
		Assert.notNull(resolvedFieldType);
		// TODO: fix the % that should be used only internally
		Assert.equals("Dynamic<%>", resolvedFieldType);
	}

	public function testResolveFieldValueTypeUInt():Void {
		var resolvedFieldType = resolveTagType('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:unsignedInteger>
					<mx:UInt/>
				</tests:unsignedInteger>
			</tests:TestPropertiesClass>
		', 158);
		Assert.notNull(resolvedFieldType);
		Assert.equals("UInt", resolvedFieldType);
	}

	public function testResolveFieldValueTypeXml():Void {
		var resolvedFieldType = resolveTagType('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:xml>
					<mx:Xml/>
				</tests:xml>
			</tests:TestPropertiesClass>
		', 146);
		Assert.notNull(resolvedFieldType);
		Assert.equals("Xml", resolvedFieldType);
	}

	public function testResolveFieldValueTypeAbstractEnumValue():Void {
		var resolvedFieldType = resolveTagType('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:abstractEnumValue>
					<tests:TestPropertyAbstractEnum/>
				</tests:abstractEnumValue>
			</tests:TestPropertiesClass>
		', 163);
		Assert.notNull(resolvedFieldType);
		Assert.equals("fixtures.TestPropertyAbstractEnum", resolvedFieldType);
	}

	public function testResolveFieldValueTypeEnumValue():Void {
		var resolvedFieldType = resolveTagType('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:enumValue>
					<tests:TestPropertyEnum/>
				</tests:enumValue>
			</tests:TestPropertiesClass>
		', 155);
		Assert.notNull(resolvedFieldType);
		Assert.equals("fixtures.TestPropertyEnum", resolvedFieldType);
	}

	public function testResolveFieldValueTypeNull():Void {
		var resolvedFieldType = resolveTagType('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:canBeNull>
					<mx:Float/>
				</tests:canBeNull>
			</tests:TestPropertiesClass>
		', 155);
		Assert.notNull(resolvedFieldType);
		Assert.equals("Float", resolvedFieldType);
	}

	public function testResolveFieldValueTypeStrict():Void {
		var resolvedFieldType = resolveTagType('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:strictlyTyped>
					<tests:TestPropertiesClass/>
				</tests:strictlyTyped>
			</tests:TestPropertiesClass>
		', 159);
		Assert.notNull(resolvedFieldType);
		Assert.equals("fixtures.TestPropertiesClass", resolvedFieldType);
	}

	public function testResolveFieldValueTypeStrictInterface():Void {
		var resolvedFieldType = resolveTagType('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:strictInterface>
					<tests:TestPropertiesClass/>
				</tests:strictlyTyped>
			</tests:strictInterface>
		', 161);
		Assert.notNull(resolvedFieldType);
		Assert.equals("fixtures.TestPropertiesClass", resolvedFieldType);
	}
	#end

	public static macro function resolveQname(qname:String):haxe.macro.Expr {
		var resolver = new MXHXMacroResolver();
		return macro $v{resolver.resolveQname(qname).qname};
	}

	public static macro function resolveQnameFieldType(qname:String, fieldName:String):haxe.macro.Expr {
		var resolver = new MXHXMacroResolver();
		var resolvedClass:IMXHXClassSymbol = cast resolver.resolveQname(qname);
		var field = Lambda.find(resolvedClass.fields, field -> field.name == fieldName);
		return macro $v{resolver.resolveQname(field.type.qname).qname};
	}

	public static macro function resolveTagType(mxhxSource:String, start:Int):haxe.macro.Expr {
		var parser = new MXHXParser(mxhxSource, "source.mxhx");
		var mxhxData = parser.parse();
		var resolver = new MXHXMacroResolver();
		resolver.registerManifest("https://ns.mxhx.dev/2024/basic", [
			"Array" => "Array",
			"Bool" => "Bool",
			"Class" => "Class",
			"Date" => "Date",
			"EReg" => "EReg",
			"Float" => "Float",
			"Function" => "haxe.Constraints.Function",
			"Int" => "Int",
			"Object" => "Any",
			"String" => "String",
			"Struct" => "Dynamic",
			"UInt" => "UInt",
			"Xml" => "Xml",
		]);

		var manifestPath = haxe.io.Path.join([Sys.getCwd(), "mxhx-manifest.xml"]);
		var content = sys.io.File.getContent(manifestPath);
		var xml = Xml.parse(content);
		var mappings:Map<String, String> = [];
		for (componentXml in xml.firstElement().elementsNamed("component")) {
			var xmlName = componentXml.get("id");
			var qname = componentXml.get("class");
			mappings.set(xmlName, qname);
		}
		resolver.registerManifest("https://ns.mxhx.dev/2024/tests", mappings);

		var offsetTag = mxhxData.findTagOrSurroundingTagContainingOffset(start);
		if (offsetTag == null) {
			return macro null;
		}
		var resolved = resolver.resolveTag(offsetTag);
		if (resolved == null) {
			return macro null;
		}
		if ((resolved is IMXHXTypeSymbol)) {
			var resolvedType:IMXHXTypeSymbol = cast resolved;
			return macro $v{resolvedType.qname};
		} else if ((resolved is IMXHXFieldSymbol)) {
			var resolvedField:IMXHXFieldSymbol = cast resolved;
			return macro $v{resolvedField.type.qname};
		}
		return macro $v{resolved.name};
	}
}
