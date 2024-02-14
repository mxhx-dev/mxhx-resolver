package mxhx.resolver.macro;

import mxhx.parser.MXHXParser;
import mxhx.symbols.IMXHXFieldSymbol;
import mxhx.symbols.IMXHXTypeSymbol;
import mxhx.resolver.macro.MXHXMacroResolver;
import utest.Test;
#if !macro
import utest.Assert;
#end

class MXHXMacroResolverTagTypeTest extends Test {
	#if !macro
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
