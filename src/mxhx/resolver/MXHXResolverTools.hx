package mxhx.resolver;

class MXHXResolverTools {
	public static function filePathAndPackToModule(filePath:String, pack:Array<String>):String {
		var index = filePath.lastIndexOf("/");
		for (i in 0...pack.length) {
			index = filePath.lastIndexOf("/", index - 1);
		}
		return StringTools.replace(filePath.substring(index + 1, filePath.length - 3), "/", ".");
	}

	public static function definitionToQname(definitionName:String, pack:Array<String>, moduleName:String, ?params:Array<String>):String {
		var qname = definitionName;
		if (pack.length > 0) {
			qname = pack.join(".") + "." + qname;
		}
		if (qname != moduleName && moduleName != "StdTypes") {
			qname = moduleName + "." + definitionName;
		}
		if (params != null && params.length > 0) {
			qname += "<";
			for (i in 0...params.length) {
				var param = params[i];
				if (i > 0) {
					qname += ",";
				}
				if (param == null) {
					qname += "%";
				} else {
					qname += param;
				}
			}
			qname += ">";
		}
		return qname;
	}
}
