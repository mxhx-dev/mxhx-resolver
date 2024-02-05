package mxhx.resolver.rtti;

import haxe.Resource;
import mxhx.internal.resolver.MXHXEnumSymbol;
import mxhx.parser.MXHXParser;
import mxhx.resolver.IMXHXClassSymbol;
import mxhx.resolver.IMXHXEnumSymbol;
import mxhx.resolver.IMXHXInterfaceSymbol;
import utest.Assert;
import utest.Test;

class MXHXRttiResolverTest extends Test {
	private static function getOffsetTag(source:String, offset:Int):IMXHXTagData {
		var parser = new MXHXParser(source, "source.mxhx");
		var mxhxData = parser.parse();
		return mxhxData.findTagOrSurroundingTagContainingOffset(offset);
	}

	private var resolver:MXHXRttiResolver;

	public function setup():Void {
		resolver = new MXHXRttiResolver();

		var content = Resource.getString("mxhx-manifest");
		var xml = Xml.parse(content);
		var mappings:Map<String, String> = [];
		for (componentXml in xml.firstElement().elementsNamed("component")) {
			var xmlName = componentXml.get("id");
			var qname = componentXml.get("class");
			mappings.set(xmlName, qname);
		}
		resolver.registerManifest("https://ns.mxhx.dev/2024/tests", mappings);
	}

	public function teardown():Void {
		resolver = null;
	}

	public function testResolveAny():Void {
		var resolved = resolver.resolveQname("Any");
		Assert.notNull(resolved);
		Assert.equals("Any", resolved.qname);
	}

	public function testResolveArray():Void {
		var resolved = resolver.resolveQname("Array");
		Assert.notNull(resolved);
		Assert.equals("Array", resolved.qname);
	}

	public function testResolveBool():Void {
		var resolved = resolver.resolveQname("Bool");
		Assert.notNull(resolved);
		Assert.equals("Bool", resolved.qname);
	}

	public function testResolveStdTypesBool():Void {
		var resolved = resolver.resolveQname("StdTypes.Bool");
		Assert.notNull(resolved);
		Assert.equals("Bool", resolved.qname);
	}

	public function testResolveDynamic():Void {
		var resolved = resolver.resolveQname("Dynamic");
		Assert.equals("Dynamic", resolved.qname);
	}

	public function testResolveEReg():Void {
		var resolved = resolver.resolveQname("EReg");
		Assert.notNull(resolved);
		Assert.equals("EReg", resolved.qname);
	}

	public function testResolveFloat():Void {
		var resolved = resolver.resolveQname("Float");
		Assert.notNull(resolved);
		Assert.equals("Float", resolved.qname);
	}

	public function testResolveStdTypesFloat():Void {
		var resolved = resolver.resolveQname("StdTypes.Float");
		Assert.notNull(resolved);
		Assert.equals("Float", resolved.qname);
	}

	public function testResolveInt():Void {
		var resolved = resolver.resolveQname("Int");
		Assert.notNull(resolved);
		Assert.equals("Int", resolved.qname);
	}

	public function testResolveStdTypesInt():Void {
		var resolved = resolver.resolveQname("StdTypes.Int");
		Assert.notNull(resolved);
		Assert.equals("Int", resolved.qname);
	}

	public function testResolveString():Void {
		var resolved = resolver.resolveQname("String");
		Assert.notNull(resolved);
		Assert.equals("String", resolved.qname);
	}

	public function testResolveUInt():Void {
		var resolved = resolver.resolveQname("UInt");
		Assert.notNull(resolved);
		Assert.equals("UInt", resolved.qname);
	}

	public function testResolveQnameFromLocalClass():Void {
		var resolved = resolver.resolveQname("fixtures.TestPropertiesClass");
		Assert.notNull(resolved);
		Assert.isOfType(resolved, IMXHXClassSymbol);
		Assert.equals("fixtures.TestPropertiesClass", resolved.qname);
	}

	public function testResolveQnameFromLocalInterface():Void {
		var resolved = resolver.resolveQname("fixtures.ITestPropertiesInterface");
		Assert.notNull(resolved);
		Assert.isOfType(resolved, IMXHXInterfaceSymbol);
		Assert.equals("fixtures.ITestPropertiesInterface", resolved.qname);
	}

	public function testResolveAnyField():Void {
		var resolvedClass:IMXHXClassSymbol = cast resolver.resolveQname("fixtures.TestPropertiesClass");
		Assert.notNull(resolvedClass);
		Assert.isOfType(resolvedClass, IMXHXClassSymbol);
		var resolvedField = Lambda.find(resolvedClass.fields, field -> field.name == "any");
		Assert.notNull(resolvedField);
		Assert.notNull(resolvedField.type);
		Assert.isOfType(resolvedField.type, IMXHXAbstractSymbol);
		Assert.equals("Any", resolvedField.type.qname);
	}

	public function testResolveArrayField():Void {
		var resolvedClass:IMXHXClassSymbol = cast resolver.resolveQname("fixtures.TestPropertiesClass");
		Assert.notNull(resolvedClass);
		Assert.isOfType(resolvedClass, IMXHXClassSymbol);
		var resolvedField = Lambda.find(resolvedClass.fields, field -> field.name == "array");
		Assert.notNull(resolvedField);
		Assert.notNull(resolvedField.type);
		Assert.isOfType(resolvedField.type, IMXHXClassSymbol);
		Assert.equals("Array<String>", resolvedField.type.qname);
	}

	public function testResolveBoolField():Void {
		var resolvedClass:IMXHXClassSymbol = cast resolver.resolveQname("fixtures.TestPropertiesClass");
		Assert.notNull(resolvedClass);
		Assert.isOfType(resolvedClass, IMXHXClassSymbol);
		var resolvedField = Lambda.find(resolvedClass.fields, field -> field.name == "boolean");
		Assert.notNull(resolvedField);
		Assert.notNull(resolvedField.type);
		Assert.isOfType(resolvedField.type, IMXHXAbstractSymbol);
		Assert.equals("Bool", resolvedField.type.qname);
	}

	public function testResolveClassField():Void {
		var resolvedClass:IMXHXClassSymbol = cast resolver.resolveQname("fixtures.TestPropertiesClass");
		Assert.notNull(resolvedClass);
		Assert.isOfType(resolvedClass, IMXHXClassSymbol);
		var resolvedField = Lambda.find(resolvedClass.fields, field -> field.name == "type");
		Assert.notNull(resolvedField);
		Assert.notNull(resolvedField.type);
		Assert.isOfType(resolvedField.type, IMXHXAbstractSymbol);
		Assert.equals("Class<Dynamic>", resolvedField.type.qname);
	}

	public function testResolveDateField():Void {
		var resolvedClass:IMXHXClassSymbol = cast resolver.resolveQname("fixtures.TestPropertiesClass");
		Assert.notNull(resolvedClass);
		Assert.isOfType(resolvedClass, IMXHXClassSymbol);
		var resolvedField = Lambda.find(resolvedClass.fields, field -> field.name == "date");
		Assert.notNull(resolvedField);
		Assert.notNull(resolvedField.type);
		Assert.isOfType(resolvedField.type, IMXHXClassSymbol);
		Assert.equals("Date", resolvedField.type.qname);
	}

	public function testResolveDynamicField():Void {
		var resolvedClass:IMXHXClassSymbol = cast resolver.resolveQname("fixtures.TestPropertiesClass");
		Assert.notNull(resolvedClass);
		Assert.isOfType(resolvedClass, IMXHXClassSymbol);
		var resolvedField = Lambda.find(resolvedClass.fields, field -> field.name == "struct");
		Assert.notNull(resolvedField);
		Assert.notNull(resolvedField.type);
		Assert.isOfType(resolvedField.type, IMXHXAbstractSymbol);
		Assert.equals("Dynamic", resolvedField.type.qname);
	}

	public function testResolveERegField():Void {
		var resolvedClass:IMXHXClassSymbol = cast resolver.resolveQname("fixtures.TestPropertiesClass");
		Assert.notNull(resolvedClass);
		Assert.isOfType(resolvedClass, IMXHXClassSymbol);
		var resolvedField = Lambda.find(resolvedClass.fields, field -> field.name == "ereg");
		Assert.notNull(resolvedField);
		Assert.notNull(resolvedField.type);
		Assert.isOfType(resolvedField.type, IMXHXClassSymbol);
		Assert.equals("EReg", resolvedField.type.qname);
	}

	public function testResolveFloatField():Void {
		var resolvedClass:IMXHXClassSymbol = cast resolver.resolveQname("fixtures.TestPropertiesClass");
		Assert.notNull(resolvedClass);
		Assert.isOfType(resolvedClass, IMXHXClassSymbol);
		var resolvedField = Lambda.find(resolvedClass.fields, field -> field.name == "float");
		Assert.notNull(resolvedField);
		Assert.notNull(resolvedField.type);
		Assert.isOfType(resolvedField.type, IMXHXAbstractSymbol);
		Assert.equals("Float", resolvedField.type.qname);
	}

	public function testResolveFunctionConstraintField():Void {
		var resolvedClass:IMXHXClassSymbol = cast resolver.resolveQname("fixtures.TestPropertiesClass");
		Assert.notNull(resolvedClass);
		Assert.isOfType(resolvedClass, IMXHXClassSymbol);
		var resolvedField = Lambda.find(resolvedClass.fields, field -> field.name == "func");
		Assert.notNull(resolvedField);
		Assert.notNull(resolvedField.type);
		Assert.isOfType(resolvedField.type, IMXHXAbstractSymbol);
		Assert.equals("haxe.Function", resolvedField.type.qname);
	}

	public function testResolveFunctionSignatureField():Void {
		var resolvedClass:IMXHXClassSymbol = cast resolver.resolveQname("fixtures.TestPropertiesClass");
		Assert.notNull(resolvedClass);
		Assert.isOfType(resolvedClass, IMXHXClassSymbol);
		var resolvedField = Lambda.find(resolvedClass.fields, field -> field.name == "funcTyped");
		Assert.notNull(resolvedField);
		Assert.notNull(resolvedField.type);
		Assert.isOfType(resolvedField.type, IMXHXAbstractSymbol);
		Assert.equals("haxe.Function", resolvedField.type.qname);
	}

	public function testResolveIntField():Void {
		var resolvedClass:IMXHXClassSymbol = cast resolver.resolveQname("fixtures.TestPropertiesClass");
		Assert.notNull(resolvedClass);
		Assert.isOfType(resolvedClass, IMXHXClassSymbol);
		var resolvedField = Lambda.find(resolvedClass.fields, field -> field.name == "integer");
		Assert.notNull(resolvedField);
		Assert.notNull(resolvedField.type);
		Assert.isOfType(resolvedField.type, IMXHXAbstractSymbol);
		Assert.equals("Int", resolvedField.type.qname);
	}

	public function testResolveStringField():Void {
		var resolvedClass:IMXHXClassSymbol = cast resolver.resolveQname("fixtures.TestPropertiesClass");
		Assert.notNull(resolvedClass);
		Assert.isOfType(resolvedClass, IMXHXClassSymbol);
		var resolvedField = Lambda.find(resolvedClass.fields, field -> field.name == "string");
		Assert.notNull(resolvedField);
		Assert.notNull(resolvedField.type);
		Assert.isOfType(resolvedField.type, IMXHXClassSymbol);
		Assert.equals("String", resolvedField.type.qname);
	}

	public function testResolveUIntField():Void {
		var resolvedClass:IMXHXClassSymbol = cast resolver.resolveQname("fixtures.TestPropertiesClass");
		Assert.notNull(resolvedClass);
		Assert.isOfType(resolvedClass, IMXHXClassSymbol);
		var resolvedField = Lambda.find(resolvedClass.fields, field -> field.name == "unsignedInteger");
		Assert.notNull(resolvedField);
		Assert.notNull(resolvedField.type);
		Assert.isOfType(resolvedField.type, IMXHXAbstractSymbol);
		Assert.equals("UInt", resolvedField.type.qname);
	}

	public function testResolveXmlField():Void {
		var resolvedClass:IMXHXClassSymbol = cast resolver.resolveQname("fixtures.TestPropertiesClass");
		Assert.notNull(resolvedClass);
		Assert.isOfType(resolvedClass, IMXHXClassSymbol);
		var resolvedField = Lambda.find(resolvedClass.fields, field -> field.name == "xml");
		Assert.notNull(resolvedField);
		Assert.notNull(resolvedField.type);
		Assert.isOfType(resolvedField.type, IMXHXClassSymbol);
		Assert.equals("Xml", resolvedField.type.qname);
	}

	public function testResolveNullField():Void {
		var resolvedClass:IMXHXClassSymbol = cast resolver.resolveQname("fixtures.TestPropertiesClass");
		Assert.notNull(resolvedClass);
		Assert.isOfType(resolvedClass, IMXHXClassSymbol);
		var resolvedField = Lambda.find(resolvedClass.fields, field -> field.name == "canBeNull");
		Assert.notNull(resolvedField);
		Assert.notNull(resolvedField.type);
		Assert.isOfType(resolvedField.type, IMXHXAbstractSymbol);
		Assert.equals("Null<Float>", resolvedField.type.qname);
	}

	public function testResolveStrictlyTypedField():Void {
		var resolvedClass:IMXHXClassSymbol = cast resolver.resolveQname("fixtures.TestPropertiesClass");
		Assert.notNull(resolvedClass);
		Assert.isOfType(resolvedClass, IMXHXClassSymbol);
		var resolvedField = Lambda.find(resolvedClass.fields, field -> field.name == "strictlyTyped");
		Assert.notNull(resolvedField);
		Assert.notNull(resolvedField.type);
		Assert.isOfType(resolvedField.type, IMXHXClassSymbol);
		Assert.equals("fixtures.TestPropertiesClass", resolvedField.type.qname);
	}

	public function testResolveStrictlyTypedInterfaceField():Void {
		var resolvedClass:IMXHXClassSymbol = cast resolver.resolveQname("fixtures.TestPropertiesClass");
		Assert.notNull(resolvedClass);
		Assert.isOfType(resolvedClass, IMXHXClassSymbol);
		var resolvedField = Lambda.find(resolvedClass.fields, field -> field.name == "strictInterface");
		Assert.notNull(resolvedField);
		Assert.notNull(resolvedField.type);
		Assert.isOfType(resolvedField.type, IMXHXInterfaceSymbol);
		Assert.equals("fixtures.ITestPropertiesInterface", resolvedField.type.qname);
	}

	public function testResolveAbstractEnumValueField():Void {
		var resolvedClass:IMXHXClassSymbol = cast resolver.resolveQname("fixtures.TestPropertiesClass");
		Assert.notNull(resolvedClass);
		Assert.isOfType(resolvedClass, IMXHXClassSymbol);
		var resolvedField = Lambda.find(resolvedClass.fields, field -> field.name == "abstractEnumValue");
		Assert.notNull(resolvedField);
		Assert.notNull(resolvedField.type);
		// Assert.isOfType(resolvedField.type, IMXHXEnumSymbol);
		Assert.equals("fixtures.TestPropertyAbstractEnum", resolvedField.type.qname);
	}

	public function testResolveEnumValueField():Void {
		var resolvedClass:IMXHXClassSymbol = cast resolver.resolveQname("fixtures.TestPropertiesClass");
		Assert.notNull(resolvedClass);
		Assert.isOfType(resolvedClass, IMXHXClassSymbol);
		var resolvedField = Lambda.find(resolvedClass.fields, field -> field.name == "enumValue");
		Assert.notNull(resolvedField);
		Assert.notNull(resolvedField.type);
		Assert.isOfType(resolvedField.type, IMXHXEnumSymbol);
		Assert.equals("fixtures.TestPropertyEnum", resolvedField.type.qname);
	}

	public function testResolveClassFromModuleWithDifferentName():Void {
		var resolvedClass:IMXHXClassSymbol = cast resolver.resolveQname("fixtures.TestPropertiesClass");
		Assert.notNull(resolvedClass);
		Assert.isOfType(resolvedClass, IMXHXClassSymbol);
		var resolvedField = Lambda.find(resolvedClass.fields, field -> field.name == "classFromModuleWithDifferentName");
		Assert.notNull(resolvedField);
		Assert.notNull(resolvedField.type);
		Assert.isOfType(resolvedField.type, IMXHXClassSymbol);
		Assert.equals("fixtures.ModuleWithClassThatHasDifferentName.ThisClassHasADifferentNameThanItsModule", resolvedField.type.qname);
	}

	public function testResolveFieldWithTypeParameter():Void {
		var resolvedClass:IMXHXClassSymbol = cast resolver.resolveQname("fixtures.ArrayCollection");
		Assert.notNull(resolvedClass);
		Assert.isOfType(resolvedClass, IMXHXClassSymbol);
		var resolvedField = Lambda.find(resolvedClass.fields, field -> field.name == "array");
		Assert.notNull(resolvedField);
		Assert.notNull(resolvedField.type);
		Assert.isOfType(resolvedField.type, IMXHXClassSymbol);
		// TODO: fix the % that should be used only internally
		Assert.equals("Array<%>", resolvedField.type.qname);
	}

	// ----- resolve tag type

	public function testResolveRootTag():Void {
		var offsetTag = getOffsetTag('
			<tests:TestClass1 xmlns:tests="https://ns.mxhx.dev/2024/tests"/>
		', 15);
		Assert.notNull(offsetTag);

		var resolved = resolver.resolveTag(offsetTag);
		Assert.notNull(resolved);
		Assert.isOfType(resolved, IMXHXTypeSymbol);
		var typeSymbol:IMXHXTypeSymbol = cast resolved;
		Assert.equals("fixtures.TestClass1", typeSymbol.qname);
	}

	public function testResolveRootTagObject():Void {
		var offsetTag = getOffsetTag('
			<mx:Object xmlns:mx="https://ns.mxhx.dev/2024/basic"/>
		', 10);
		Assert.notNull(offsetTag);

		var resolved = resolver.resolveTag(offsetTag);
		Assert.notNull(resolved);
		Assert.isOfType(resolved, IMXHXTypeSymbol);
		var typeSymbol:IMXHXTypeSymbol = cast resolved;
		Assert.equals("Any", typeSymbol.qname);
	}

	public function testResolveDeclarationsArray():Void {
		var offsetTag = getOffsetTag('
			<tests:TestClass1 xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<mx:Declarations>
					<mx:Array type="Float"/>
				</mx:Declarations>
			</tests:TestClass1>
		', 142);
		Assert.notNull(offsetTag);

		var resolved = resolver.resolveTag(offsetTag);
		Assert.notNull(resolved);
		Assert.isOfType(resolved, IMXHXTypeSymbol);
		var typeSymbol:IMXHXTypeSymbol = cast resolved;
		Assert.equals("Array<Float>", typeSymbol.qname);
	}

	public function testResolveDeclarationsBool():Void {
		var offsetTag = getOffsetTag('
			<tests:TestClass1 xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<mx:Declarations>
					<mx:Bool/>
				</mx:Declarations>
			</tests:TestClass1>
		', 142);
		Assert.notNull(offsetTag);

		var resolved = resolver.resolveTag(offsetTag);
		Assert.notNull(resolved);
		Assert.isOfType(resolved, IMXHXTypeSymbol);
		var typeSymbol:IMXHXTypeSymbol = cast resolved;
		Assert.equals("Bool", typeSymbol.qname);
	}

	public function testResolveDeclarationsDate():Void {
		var offsetTag = getOffsetTag('
			<tests:TestClass1 xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<mx:Declarations>
					<mx:Date/>
				</mx:Declarations>
			</tests:TestClass1>
		', 142);
		Assert.notNull(offsetTag);

		var resolved = resolver.resolveTag(offsetTag);
		Assert.notNull(resolved);
		Assert.isOfType(resolved, IMXHXTypeSymbol);
		var typeSymbol:IMXHXTypeSymbol = cast resolved;
		Assert.equals("Date", typeSymbol.qname);
	}

	public function testResolveDeclarationsEReg():Void {
		var offsetTag = getOffsetTag('
			<tests:TestClass1 xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<mx:Declarations>
					<mx:EReg/>
				</mx:Declarations>
			</tests:TestClass1>
		', 142);
		Assert.notNull(offsetTag);

		var resolved = resolver.resolveTag(offsetTag);
		Assert.notNull(resolved);
		Assert.isOfType(resolved, IMXHXTypeSymbol);
		var typeSymbol:IMXHXTypeSymbol = cast resolved;
		Assert.equals("EReg", typeSymbol.qname);
	}

	public function testResolveDeclarationsFloat():Void {
		var offsetTag = getOffsetTag('
			<tests:TestClass1 xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<mx:Declarations>
					<mx:Float/>
				</mx:Declarations>
			</tests:TestClass1>
		', 142);
		Assert.notNull(offsetTag);

		var resolved = resolver.resolveTag(offsetTag);
		Assert.notNull(resolved);
		Assert.isOfType(resolved, IMXHXTypeSymbol);
		var typeSymbol:IMXHXTypeSymbol = cast resolved;
		Assert.equals("Float", typeSymbol.qname);
	}

	public function testResolveDeclarationsFunction():Void {
		var offsetTag = getOffsetTag('
			<tests:TestClass1 xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<mx:Declarations>
					<mx:Function/>
				</mx:Declarations>
			</tests:TestClass1>
		', 142);
		Assert.notNull(offsetTag);

		var resolved = resolver.resolveTag(offsetTag);
		Assert.notNull(resolved);
		Assert.isOfType(resolved, IMXHXTypeSymbol);
		var typeSymbol:IMXHXTypeSymbol = cast resolved;
		Assert.equals("haxe.Function", typeSymbol.qname);
	}

	public function testResolveDeclarationsInt():Void {
		var offsetTag = getOffsetTag('
			<tests:TestClass1 xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<mx:Declarations>
					<mx:Int/>
				</mx:Declarations>
			</tests:TestClass1>
		', 142);
		Assert.notNull(offsetTag);

		var resolved = resolver.resolveTag(offsetTag);
		Assert.notNull(resolved);
		Assert.isOfType(resolved, IMXHXTypeSymbol);
		var typeSymbol:IMXHXTypeSymbol = cast resolved;
		Assert.equals("Int", typeSymbol.qname);
	}

	public function testResolveDeclarationsString():Void {
		var offsetTag = getOffsetTag('
			<tests:TestClass1 xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<mx:Declarations>
					<mx:String/>
				</mx:Declarations>
			</tests:TestClass1>
		', 142);
		Assert.notNull(offsetTag);

		var resolved = resolver.resolveTag(offsetTag);
		Assert.notNull(resolved);
		Assert.isOfType(resolved, IMXHXTypeSymbol);
		var typeSymbol:IMXHXTypeSymbol = cast resolved;
		Assert.equals("String", typeSymbol.qname);
	}

	public function testResolveDeclarationsStruct():Void {
		var offsetTag = getOffsetTag('
			<tests:TestClass1 xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<mx:Declarations>
					<mx:Struct/>
				</mx:Declarations>
			</tests:TestClass1>
		', 142);
		Assert.notNull(offsetTag);

		var resolved = resolver.resolveTag(offsetTag);
		Assert.notNull(resolved);
		Assert.isOfType(resolved, IMXHXTypeSymbol);
		var typeSymbol:IMXHXTypeSymbol = cast resolved;
		// TODO: should this have a type parameter?
		Assert.equals("Dynamic", typeSymbol.qname);
	}

	public function testResolveDeclarationsUInt():Void {
		var offsetTag = getOffsetTag('
			<tests:TestClass1 xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<mx:Declarations>
					<mx:UInt/>
				</mx:Declarations>
			</tests:TestClass1>
		', 142);
		Assert.notNull(offsetTag);

		var resolved = resolver.resolveTag(offsetTag);
		Assert.notNull(resolved);
		Assert.isOfType(resolved, IMXHXTypeSymbol);
		var typeSymbol:IMXHXTypeSymbol = cast resolved;
		Assert.equals("UInt", typeSymbol.qname);
	}

	public function testResolveDeclarationsXml():Void {
		var offsetTag = getOffsetTag('
			<tests:TestClass1 xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<mx:Declarations>
					<mx:Xml/>
				</mx:Declarations>
			</tests:TestClass1>
		', 142);
		Assert.notNull(offsetTag);

		var resolved = resolver.resolveTag(offsetTag);
		Assert.notNull(resolved);
		Assert.isOfType(resolved, IMXHXTypeSymbol);
		var typeSymbol:IMXHXTypeSymbol = cast resolved;
		Assert.equals("Xml", typeSymbol.qname);
	}

	// ---- resolve field type

	public function testResolveFieldTypeAny():Void {
		var offsetTag = getOffsetTag('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:any>
					<mx:Float/>
				</tests:any>
			</tests:TestPropertiesClass>
		', 132);
		Assert.notNull(offsetTag);

		var resolved = resolver.resolveTag(offsetTag);
		Assert.notNull(resolved);
		Assert.isOfType(resolved, IMXHXFieldSymbol);
		var fieldSymbol:IMXHXFieldSymbol = cast resolved;
		Assert.notNull(fieldSymbol.type);
		Assert.isOfType(fieldSymbol.type, IMXHXAbstractSymbol);
		Assert.equals("Any", fieldSymbol.type.qname);
	}

	public function testResolveFieldTypeArray():Void {
		var offsetTag = getOffsetTag('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:array>
					<mx:Array/>
				</tests:array>
			</tests:TestPropertiesClass>
		', 132);
		Assert.notNull(offsetTag);

		var resolved = resolver.resolveTag(offsetTag);
		Assert.notNull(resolved);
		Assert.isOfType(resolved, IMXHXFieldSymbol);
		var fieldSymbol:IMXHXFieldSymbol = cast resolved;
		Assert.notNull(fieldSymbol.type);
		Assert.isOfType(fieldSymbol.type, IMXHXClassSymbol);
		Assert.equals("Array<String>", fieldSymbol.type.qname);
	}

	public function testResolveFieldTypeBool():Void {
		var offsetTag = getOffsetTag('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:boolean>
					<mx:Bool/>
				</tests:boolean>
			</tests:TestPropertiesClass>
		', 132);
		Assert.notNull(offsetTag);

		var resolved = resolver.resolveTag(offsetTag);
		Assert.notNull(resolved);
		Assert.isOfType(resolved, IMXHXFieldSymbol);
		var fieldSymbol:IMXHXFieldSymbol = cast resolved;
		Assert.notNull(fieldSymbol.type);
		Assert.isOfType(fieldSymbol.type, IMXHXAbstractSymbol);
		Assert.equals("Bool", fieldSymbol.type.qname);
	}

	public function testResolveFieldTypeClass():Void {
		var offsetTag = getOffsetTag('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:type>
					<mx:Class>Float</mx:Class>
				</tests:type>
			</tests:TestPropertiesClass>
		', 132);
		Assert.notNull(offsetTag);

		var resolved = resolver.resolveTag(offsetTag);
		Assert.notNull(resolved);
		Assert.isOfType(resolved, IMXHXFieldSymbol);
		var fieldSymbol:IMXHXFieldSymbol = cast resolved;
		Assert.notNull(fieldSymbol.type);
		Assert.isOfType(fieldSymbol.type, IMXHXAbstractSymbol);
		Assert.equals("Class<Dynamic>", fieldSymbol.type.qname);
	}

	public function testResolveFieldTypeDate():Void {
		var offsetTag = getOffsetTag('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:date>
					<mx:Date/>
				</tests:date>
			</tests:TestPropertiesClass>
		', 132);
		Assert.notNull(offsetTag);

		var resolved = resolver.resolveTag(offsetTag);
		Assert.notNull(resolved);
		Assert.isOfType(resolved, IMXHXFieldSymbol);
		var fieldSymbol:IMXHXFieldSymbol = cast resolved;
		Assert.notNull(fieldSymbol.type);
		Assert.isOfType(fieldSymbol.type, IMXHXClassSymbol);
		Assert.equals("Date", fieldSymbol.type.qname);
	}

	public function testResolveFieldTypeDynamic():Void {
		var offsetTag = getOffsetTag('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:struct>
					<mx:Struct/>
				</tests:struct>
			</tests:TestPropertiesClass>
		', 132);
		Assert.notNull(offsetTag);

		var resolved = resolver.resolveTag(offsetTag);
		Assert.notNull(resolved);
		Assert.isOfType(resolved, IMXHXFieldSymbol);
		var fieldSymbol:IMXHXFieldSymbol = cast resolved;
		Assert.notNull(fieldSymbol.type);
		Assert.isOfType(fieldSymbol.type, IMXHXAbstractSymbol);
		Assert.equals("Dynamic", fieldSymbol.type.qname);
	}

	public function testResolveFieldTypeEReg():Void {
		var offsetTag = getOffsetTag('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:ereg>
					<mx:EReg/>
				</tests:ereg>
			</tests:TestPropertiesClass>
		', 132);
		Assert.notNull(offsetTag);

		var resolved = resolver.resolveTag(offsetTag);
		Assert.notNull(resolved);
		Assert.isOfType(resolved, IMXHXFieldSymbol);
		var fieldSymbol:IMXHXFieldSymbol = cast resolved;
		Assert.notNull(fieldSymbol.type);
		Assert.isOfType(fieldSymbol.type, IMXHXClassSymbol);
		Assert.equals("EReg", fieldSymbol.type.qname);
	}

	public function testResolveFieldTypeFloat():Void {
		var offsetTag = getOffsetTag('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:float>
					<mx:Float/>
				</tests:float>
			</tests:TestPropertiesClass>
		', 132);
		Assert.notNull(offsetTag);

		var resolved = resolver.resolveTag(offsetTag);
		Assert.notNull(resolved);
		Assert.isOfType(resolved, IMXHXFieldSymbol);
		var fieldSymbol:IMXHXFieldSymbol = cast resolved;
		Assert.notNull(fieldSymbol.type);
		Assert.isOfType(fieldSymbol.type, IMXHXAbstractSymbol);
		Assert.equals("Float", fieldSymbol.type.qname);
	}

	public function testResolveFieldTypeFunction():Void {
		var offsetTag = getOffsetTag('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:func>
					<mx:Function/>
				</tests:func>
			</tests:TestPropertiesClass>
		', 132);
		Assert.notNull(offsetTag);

		var resolved = resolver.resolveTag(offsetTag);
		Assert.notNull(resolved);
		Assert.isOfType(resolved, IMXHXFieldSymbol);
		var fieldSymbol:IMXHXFieldSymbol = cast resolved;
		Assert.notNull(fieldSymbol.type);
		Assert.isOfType(fieldSymbol.type, IMXHXAbstractSymbol);
		Assert.equals("haxe.Function", fieldSymbol.type.qname);
	}

	public function testResolveFieldTypeFunctionSignature():Void {
		var offsetTag = getOffsetTag('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:funcTyped>
					<mx:Function/>
				</tests:funcTyped>
			</tests:TestPropertiesClass>
		', 132);
		Assert.notNull(offsetTag);

		var resolved = resolver.resolveTag(offsetTag);
		Assert.notNull(resolved);
		Assert.isOfType(resolved, IMXHXFieldSymbol);
		var fieldSymbol:IMXHXFieldSymbol = cast resolved;
		Assert.notNull(fieldSymbol.type);
		Assert.isOfType(fieldSymbol.type, IMXHXAbstractSymbol);
		Assert.equals("haxe.Function", fieldSymbol.type.qname);
	}

	public function testResolveFieldTypeInt():Void {
		var offsetTag = getOffsetTag('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:integer>
					<mx:Int/>
				</tests:integer>
			</tests:TestPropertiesClass>
		', 132);
		Assert.notNull(offsetTag);

		var resolved = resolver.resolveTag(offsetTag);
		Assert.notNull(resolved);
		Assert.isOfType(resolved, IMXHXFieldSymbol);
		var fieldSymbol:IMXHXFieldSymbol = cast resolved;
		Assert.notNull(fieldSymbol.type);
		Assert.isOfType(fieldSymbol.type, IMXHXAbstractSymbol);
		Assert.equals("Int", fieldSymbol.type.qname);
	}

	public function testResolveFieldTypeString():Void {
		var offsetTag = getOffsetTag('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:string>
					<mx:String/>
				</tests:string>
			</tests:TestPropertiesClass>
		', 132);
		Assert.notNull(offsetTag);

		var resolved = resolver.resolveTag(offsetTag);
		Assert.notNull(resolved);
		Assert.isOfType(resolved, IMXHXFieldSymbol);
		var fieldSymbol:IMXHXFieldSymbol = cast resolved;
		Assert.notNull(fieldSymbol.type);
		Assert.isOfType(fieldSymbol.type, IMXHXClassSymbol);
		Assert.equals("String", fieldSymbol.type.qname);
	}

	public function testResolveFieldTypeStruct():Void {
		var offsetTag = getOffsetTag('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:struct>
					<mx:Struct/>
				</tests:struct>
			</tests:TestPropertiesClass>
		', 132);
		Assert.notNull(offsetTag);

		var resolved = resolver.resolveTag(offsetTag);
		Assert.notNull(resolved);
		Assert.isOfType(resolved, IMXHXFieldSymbol);
		var fieldSymbol:IMXHXFieldSymbol = cast resolved;
		Assert.notNull(fieldSymbol.type);
		Assert.isOfType(fieldSymbol.type, IMXHXAbstractSymbol);
		Assert.equals("Dynamic", fieldSymbol.type.qname);
	}

	public function testResolveFieldTypeUInt():Void {
		var offsetTag = getOffsetTag('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:unsignedInteger>
					<mx:UInt/>
				</tests:unsignedInteger>
			</tests:TestPropertiesClass>
		', 132);
		Assert.notNull(offsetTag);

		var resolved = resolver.resolveTag(offsetTag);
		Assert.notNull(resolved);
		Assert.isOfType(resolved, IMXHXFieldSymbol);
		var fieldSymbol:IMXHXFieldSymbol = cast resolved;
		Assert.notNull(fieldSymbol.type);
		Assert.isOfType(fieldSymbol.type, IMXHXAbstractSymbol);
		Assert.equals("UInt", fieldSymbol.type.qname);
	}

	public function testResolveFieldTypeXml():Void {
		var offsetTag = getOffsetTag('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:xml>
					<mx:Xml/>
				</tests:xml>
			</tests:TestPropertiesClass>
		', 132);
		Assert.notNull(offsetTag);

		var resolved = resolver.resolveTag(offsetTag);
		Assert.notNull(resolved);
		Assert.isOfType(resolved, IMXHXFieldSymbol);
		var fieldSymbol:IMXHXFieldSymbol = cast resolved;
		Assert.notNull(fieldSymbol.type);
		Assert.isOfType(fieldSymbol.type, IMXHXClassSymbol);
		Assert.equals("Xml", fieldSymbol.type.qname);
	}

	public function testResolveFieldTypeAbstractEnumValue():Void {
		var offsetTag = getOffsetTag('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:abstractEnumValue>
					<tests:TestPropertyAbstractEnum/>
				</tests:abstractEnumValue>
			</tests:TestPropertiesClass>
		', 132);
		Assert.notNull(offsetTag);

		var resolved = resolver.resolveTag(offsetTag);
		Assert.notNull(resolved);
		Assert.isOfType(resolved, IMXHXFieldSymbol);
		var fieldSymbol:IMXHXFieldSymbol = cast resolved;
		Assert.notNull(fieldSymbol.type);
		// Assert.isOfType(fieldSymbol.type, IMXHXEnumSymbol);
		Assert.equals("fixtures.TestPropertyAbstractEnum", fieldSymbol.type.qname);
	}

	public function testResolveFieldTypeEnumValue():Void {
		var offsetTag = getOffsetTag('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:enumValue>
					<tests:TestPropertyEnum/>
				</tests:enumValue>
			</tests:TestPropertiesClass>
		', 132);
		Assert.notNull(offsetTag);

		var resolved = resolver.resolveTag(offsetTag);
		Assert.notNull(resolved);
		Assert.isOfType(resolved, IMXHXFieldSymbol);
		var fieldSymbol:IMXHXFieldSymbol = cast resolved;
		Assert.notNull(fieldSymbol.type);
		Assert.isOfType(fieldSymbol.type, IMXHXEnumSymbol);
		Assert.equals("fixtures.TestPropertyEnum", fieldSymbol.type.qname);
	}

	public function testResolveFieldTypeNull():Void {
		var offsetTag = getOffsetTag('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:canBeNull>
					<tests:Float/>
				</tests:canBeNull>
			</tests:TestPropertiesClass>
		', 132);
		Assert.notNull(offsetTag);

		var resolved = resolver.resolveTag(offsetTag);
		Assert.notNull(resolved);
		Assert.isOfType(resolved, IMXHXFieldSymbol);
		var fieldSymbol:IMXHXFieldSymbol = cast resolved;
		Assert.notNull(fieldSymbol.type);
		Assert.isOfType(fieldSymbol.type, IMXHXAbstractSymbol);
		Assert.equals("Null<Float>", fieldSymbol.type.qname);
	}

	public function testResolveFieldTypeStrict():Void {
		var offsetTag = getOffsetTag('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:strictlyTyped>
					<tests:TestPropertiesClass/>
				</tests:strictlyTyped>
			</tests:TestPropertiesClass>
		', 132);
		Assert.notNull(offsetTag);

		var resolved = resolver.resolveTag(offsetTag);
		Assert.notNull(resolved);
		Assert.isOfType(resolved, IMXHXFieldSymbol);
		var fieldSymbol:IMXHXFieldSymbol = cast resolved;
		Assert.notNull(fieldSymbol.type);
		Assert.isOfType(fieldSymbol.type, IMXHXClassSymbol);
		Assert.equals("fixtures.TestPropertiesClass", fieldSymbol.type.qname);
	}

	public function testResolveFieldTypeStrictInterface():Void {
		var offsetTag = getOffsetTag('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:strictInterface>
					<tests:TestPropertiesClass/>
				</tests:strictInterface>
			</tests:TestPropertiesClass>
		', 132);
		Assert.notNull(offsetTag);

		var resolved = resolver.resolveTag(offsetTag);
		Assert.notNull(resolved);
		Assert.isOfType(resolved, IMXHXFieldSymbol);
		var fieldSymbol:IMXHXFieldSymbol = cast resolved;
		Assert.notNull(fieldSymbol.type);
		Assert.isOfType(fieldSymbol.type, IMXHXInterfaceSymbol);
		Assert.equals("fixtures.ITestPropertiesInterface", fieldSymbol.type.qname);
	}

	// ---- resolve field value type

	public function testResolveFieldValueTypeAny():Void {
		var offsetTag = getOffsetTag('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:any>
					<mx:Float/>
				</tests:any>
			</tests:TestPropertiesClass>
		', 146);
		Assert.notNull(offsetTag);

		var resolved = resolver.resolveTag(offsetTag);
		Assert.notNull(resolved);
		Assert.isOfType(resolved, IMXHXTypeSymbol);
		var typeSymbol:IMXHXTypeSymbol = cast resolved;
		// the field is typed as Any, but the value is more specific
		Assert.equals("Float", typeSymbol.qname);
	}

	public function testResolveFieldValueTypeArray():Void {
		var offsetTag = getOffsetTag('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:array>
					<mx:Array type="String"/>
				</tests:array>
			</tests:TestPropertiesClass>
		', 148);
		Assert.notNull(offsetTag);

		var resolved = resolver.resolveTag(offsetTag);
		Assert.notNull(resolved);
		Assert.isOfType(resolved, IMXHXTypeSymbol);
		var typeSymbol:IMXHXTypeSymbol = cast resolved;
		Assert.equals("Array<String>", typeSymbol.qname);
	}

	public function testResolveFieldValueTypeBool():Void {
		var offsetTag = getOffsetTag('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:boolean>
					<mx:Bool/>
				</tests:boolean>
			</tests:TestPropertiesClass>
		', 150);
		Assert.notNull(offsetTag);

		var resolved = resolver.resolveTag(offsetTag);
		Assert.notNull(resolved);
		Assert.isOfType(resolved, IMXHXTypeSymbol);
		var typeSymbol:IMXHXTypeSymbol = cast resolved;
		Assert.equals("Bool", typeSymbol.qname);
	}

	public function testResolveFieldValueTypeClass():Void {
		var offsetTag = getOffsetTag('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:type>
					<mx:Class>Float</mx:Class>
				</tests:type>
			</tests:TestPropertiesClass>
		', 147);
		Assert.notNull(offsetTag);

		var resolved = resolver.resolveTag(offsetTag);
		Assert.notNull(resolved);
		Assert.isOfType(resolved, IMXHXTypeSymbol);
		var typeSymbol:IMXHXTypeSymbol = cast resolved;
		// TODO: should this have a type parameter?
		Assert.equals("Class", typeSymbol.qname);
	}

	public function testResolveFieldValueTypeDate():Void {
		var offsetTag = getOffsetTag('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:date>
					<mx:Date/>
				</tests:date>
			</tests:TestPropertiesClass>
		', 147);
		Assert.notNull(offsetTag);

		var resolved = resolver.resolveTag(offsetTag);
		Assert.notNull(resolved);
		Assert.isOfType(resolved, IMXHXTypeSymbol);
		var typeSymbol:IMXHXTypeSymbol = cast resolved;
		Assert.equals("Date", typeSymbol.qname);
	}

	public function testResolveFieldValueTypeDynamic():Void {
		var offsetTag = getOffsetTag('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:struct>
					<mx:Struct/>
				</tests:struct>
			</tests:TestPropertiesClass>
		', 149);
		Assert.notNull(offsetTag);

		var resolved = resolver.resolveTag(offsetTag);
		Assert.notNull(resolved);
		Assert.isOfType(resolved, IMXHXTypeSymbol);
		var typeSymbol:IMXHXTypeSymbol = cast resolved;
		// TODO: should this have a type parameter?
		Assert.equals("Dynamic", typeSymbol.qname);
	}

	public function testResolveFieldValueTypeEReg():Void {
		var offsetTag = getOffsetTag('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:ereg>
					<mx:EReg/>
				</tests:ereg>
			</tests:TestPropertiesClass>
		', 147);
		Assert.notNull(offsetTag);

		var resolved = resolver.resolveTag(offsetTag);
		Assert.notNull(resolved);
		Assert.isOfType(resolved, IMXHXTypeSymbol);
		var typeSymbol:IMXHXTypeSymbol = cast resolved;
		Assert.equals("EReg", typeSymbol.qname);
	}

	public function testResolveFieldValueTypeFloat():Void {
		var offsetTag = getOffsetTag('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:float>
					<mx:Float/>
				</tests:float>
			</tests:TestPropertiesClass>
		', 148);
		Assert.notNull(offsetTag);

		var resolved = resolver.resolveTag(offsetTag);
		Assert.notNull(resolved);
		Assert.isOfType(resolved, IMXHXTypeSymbol);
		var typeSymbol:IMXHXTypeSymbol = cast resolved;
		Assert.equals("Float", typeSymbol.qname);
	}

	public function testResolveFieldValueTypeFunction():Void {
		var offsetTag = getOffsetTag('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:func>
					<mx:Function/>
				</tests:func>
			</tests:TestPropertiesClass>
		', 147);
		Assert.notNull(offsetTag);

		var resolved = resolver.resolveTag(offsetTag);
		Assert.notNull(resolved);
		Assert.isOfType(resolved, IMXHXTypeSymbol);
		var typeSymbol:IMXHXTypeSymbol = cast resolved;
		Assert.equals("haxe.Function", typeSymbol.qname);
	}

	public function testResolveFieldValueTypeFunctionSignature():Void {
		var offsetTag = getOffsetTag('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:funcTyped>
					<mx:Function/>
				</tests:funcTyped>
			</tests:TestPropertiesClass>
		', 152);
		Assert.notNull(offsetTag);

		var resolved = resolver.resolveTag(offsetTag);
		Assert.notNull(resolved);
		Assert.isOfType(resolved, IMXHXTypeSymbol);
		var typeSymbol:IMXHXTypeSymbol = cast resolved;
		Assert.equals("haxe.Function", typeSymbol.qname);
	}

	public function testResolveFieldValueTypeInt():Void {
		var offsetTag = getOffsetTag('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:integer>
					<mx:Int/>
				</tests:integer>
			</tests:TestPropertiesClass>
		', 150);
		Assert.notNull(offsetTag);

		var resolved = resolver.resolveTag(offsetTag);
		Assert.notNull(resolved);
		Assert.isOfType(resolved, IMXHXTypeSymbol);
		var typeSymbol:IMXHXTypeSymbol = cast resolved;
		Assert.equals("Int", typeSymbol.qname);
	}

	public function testResolveFieldValueTypeString():Void {
		var offsetTag = getOffsetTag('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:string>
					<mx:String/>
				</tests:string>
			</tests:TestPropertiesClass>
		', 149);
		Assert.notNull(offsetTag);

		var resolved = resolver.resolveTag(offsetTag);
		Assert.notNull(resolved);
		Assert.isOfType(resolved, IMXHXTypeSymbol);
		var typeSymbol:IMXHXTypeSymbol = cast resolved;
		Assert.equals("String", typeSymbol.qname);
	}

	public function testResolveFieldValueTypeStruct():Void {
		var offsetTag = getOffsetTag('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:struct>
					<mx:Struct/>
				</tests:struct>
			</tests:TestPropertiesClass>
		', 149);
		Assert.notNull(offsetTag);

		var resolved = resolver.resolveTag(offsetTag);
		Assert.notNull(resolved);
		Assert.isOfType(resolved, IMXHXTypeSymbol);
		var typeSymbol:IMXHXTypeSymbol = cast resolved;
		// TODO: should this have a type parameter?
		Assert.equals("Dynamic", typeSymbol.qname);
	}

	public function testResolveFieldValueTypeUInt():Void {
		var offsetTag = getOffsetTag('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:unsignedInteger>
					<mx:UInt/>
				</tests:unsignedInteger>
			</tests:TestPropertiesClass>
		', 158);
		Assert.notNull(offsetTag);

		var resolved = resolver.resolveTag(offsetTag);
		Assert.notNull(resolved);
		Assert.isOfType(resolved, IMXHXTypeSymbol);
		var typeSymbol:IMXHXTypeSymbol = cast resolved;
		Assert.equals("UInt", typeSymbol.qname);
	}

	public function testResolveFieldValueTypeXml():Void {
		var offsetTag = getOffsetTag('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:xml>
					<mx:Xml/>
				</tests:xml>
			</tests:TestPropertiesClass>
		', 146);
		Assert.notNull(offsetTag);

		var resolved = resolver.resolveTag(offsetTag);
		Assert.notNull(resolved);
		Assert.isOfType(resolved, IMXHXTypeSymbol);
		var typeSymbol:IMXHXTypeSymbol = cast resolved;
		Assert.equals("Xml", typeSymbol.qname);
	}

	public function testResolveFieldValueTypeAbstractEnumValue():Void {
		var offsetTag = getOffsetTag('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:abstractEnumValue>
					<tests:TestPropertyAbstractEnum/>
				</tests:abstractEnumValue>
			</tests:TestPropertiesClass>
		', 163);
		Assert.notNull(offsetTag);

		var resolved = resolver.resolveTag(offsetTag);
		#if interp
		Assert.notNull(resolved);
		Assert.isOfType(resolved, IMXHXTypeSymbol);
		var typeSymbol:IMXHXTypeSymbol = cast resolved;
		Assert.equals("fixtures.TestPropertyAbstractEnum", typeSymbol.qname);
		#else
		Assert.isNull(resolved);
		#end
	}

	public function testResolveFieldValueTypeEnumValue():Void {
		var offsetTag = getOffsetTag('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:enumValue>
					<tests:TestPropertyEnum/>
				</tests:enumValue>
			</tests:TestPropertiesClass>
		', 155);
		Assert.notNull(offsetTag);

		var resolved = resolver.resolveTag(offsetTag);
		Assert.notNull(resolved);
		Assert.isOfType(resolved, IMXHXEnumSymbol);
		var typeSymbol:IMXHXEnumSymbol = cast resolved;
		Assert.equals("fixtures.TestPropertyEnum", typeSymbol.qname);
	}

	public function testResolveFieldValueTypeNull():Void {
		var offsetTag = getOffsetTag('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:canBeNull>
					<mx:Float/>
				</tests:canBeNull>
			</tests:TestPropertiesClass>
		', 155);
		Assert.notNull(offsetTag);

		var resolved = resolver.resolveTag(offsetTag);
		Assert.notNull(resolved);
		Assert.isOfType(resolved, IMXHXTypeSymbol);
		var typeSymbol:IMXHXTypeSymbol = cast resolved;
		Assert.equals("Float", typeSymbol.qname);
	}

	public function testResolveFieldValueTypeStrict():Void {
		var offsetTag = getOffsetTag('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:strictlyTyped>
					<tests:TestPropertiesClass/>
				</tests:strictlyTyped>
			</tests:TestPropertiesClass>
		', 159);
		Assert.notNull(offsetTag);

		var resolved = resolver.resolveTag(offsetTag);
		Assert.notNull(resolved);
		Assert.isOfType(resolved, IMXHXClassSymbol);
		var typeSymbol:IMXHXClassSymbol = cast resolved;
		Assert.equals("fixtures.TestPropertiesClass", typeSymbol.qname);
	}

	public function testResolveFieldValueTypeStrictInterface():Void {
		var offsetTag = getOffsetTag('
			<tests:TestPropertiesClass xmlns:mx="https://ns.mxhx.dev/2024/basic" xmlns:tests="https://ns.mxhx.dev/2024/tests">
				<tests:strictInterface>
					<tests:TestPropertiesClass/>
				</tests:strictInterface>
			</tests:TestPropertiesClass>
		', 161);
		Assert.notNull(offsetTag);

		var resolved = resolver.resolveTag(offsetTag);
		Assert.notNull(resolved);
		Assert.isOfType(resolved, IMXHXClassSymbol);
		var typeSymbol:IMXHXClassSymbol = cast resolved;
		Assert.equals("fixtures.TestPropertiesClass", typeSymbol.qname);
	}
}
