import io.colyseus.serializer.schema.Schema;
import io.colyseus.serializer.schema.types.*;

class Stuff extends Schema {
	@:type("string")
	public var message: String = "";

	@:type("string")
	public var chatHist: String = "";

	@:type("string")
	public var recvprev: String = "";

	@:type("int32")
	public var axY: Int = 0;

}
