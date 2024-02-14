package mxhx.resolver.macro;

import mxhx.symbols.IMXHXClassSymbol;
import utest.Test;
#if !macro
import utest.Assert;
#end

class MXHXMacroResolverQnameFieldTest extends Test {
	#if !macro
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
	#end

	public static macro function resolveQnameFieldType(qname:String, fieldName:String):haxe.macro.Expr {
		var resolver = new MXHXMacroResolver();
		var resolvedClass:IMXHXClassSymbol = cast resolver.resolveQname(qname);
		var field = Lambda.find(resolvedClass.fields, field -> field.name == fieldName);
		return macro $v{resolver.resolveQname(field.type.qname).qname};
	}
}
