package fixtures;

abstract TestAbstractFromModuleType(ModuleType) from ModuleType to ModuleType {
	@:from public static function fromFloat(float:Float):TestAbstractFromModuleType {
		return new ModuleType(float);
	}
}

class ModuleType {
	public var value:Float;

	public function new(value:Float) {
		this.value = value;
	}
}
