package fixtures;

class TestInlineComponentClassAbstractFromClass {
	public function new() {}

	public var classAbstractProperty:FromClassAbstract;
}

class Underlying {
	public var c:Class<Dynamic>;

	public function new(c:Class<Dynamic>) {
		this.c = c;
	}
}

abstract FromClassAbstract(Underlying) from Underlying to Underlying {
	@:from
	public static function fromClass(c:Class<Dynamic>):FromClassAbstract {
		return new Underlying(c);
	}
}
