import ballerina/io;
import asus/json_rpc.server;

type Nip record {|
    int x;
    int y;
|};

string str = "{\"jsonrpc\":\"2.0\",\"method\":\"add\",\"params\":{\"x\":89, \"y\":100},\"id\":10}";
public function main() {
    io:println("Hello, World!");
    server:serverFunction("add", addFunction);
    io:println(server:messageCatcher(str));
}


public function addFunction(server:InputFunc ifs) returns int|error{
  json nips = <json> ifs;
  Nip nip = check nips.cloneWithType();
  return nip.x + nip.y;
}
