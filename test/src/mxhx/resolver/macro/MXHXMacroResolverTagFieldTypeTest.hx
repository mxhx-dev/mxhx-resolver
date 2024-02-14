package mxhx.resolver.macro;

import mxhx.parser.MXHXParser;
import mxhx.resolver.IMXHXFieldSymbol;
import mxhx.resolver.IMXHXTypeSymbol;
import mxhx.resolver.macro.MXHXMacroResolver;
import utest.Test;
#if !macro
import utest.Assert;
#end

class MXHXMacroResolverTagFieldTypeTest extends Test {
	#if !macro
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
	#end

	public static macro function resolveTagType(mxhxSource:String, start:Int):haxe.macro.Expr {
		var parser = new MXHXParser(mxhxSource, "source.mxhx");
		var mxhxData = parser.parse();
		var resolver = new MXHXMacroResolver();

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
