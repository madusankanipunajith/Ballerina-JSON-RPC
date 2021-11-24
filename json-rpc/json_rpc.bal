import ballerina/io;
import json_rpc.server;

type Nip record {|
    int x;
    int y;
|};

type Sip record {|
    int[] arr;
|};

// json rpc messages come from client
string str = "{\"jsonrpc\":\"2.0\",\"method\":\"add\",\"params\":{\"x\":89, \"y\":100},\"id\":10}";
string str2 = "{\"foo\": \"boo\"}";
string str3 = "[{\"jsonrpc\":\"2.0\",\"method\":\"add\",\"params\":{\"x\":89, \"y\":100},\"id\":10}, {\"jsonrpc\":\"2.0\",\"method\":\"sub\",\"params\":{\"x\":89, \"y\":100},\"id\":10}]";
string str4 = "{\"jsonrpc\":\"2.0\",\"method\":\"mult\",\"params\":[10,20,30],\"id\":10}";
string str5 = "{\"jsonrpc\":\"2.0\",\"method\":\"mult\",\"params\":550,\"id\":10}";
public function main() {

    io:println("hello");
    server:serverFunction("add", addFunction);
    server:serverFunction("sub", subFunction);

    //validator:Error|validator:Response|runner:BatchResponse|error? messageCatcher = server:messageCatcher(str3);
    io:println(server:messageCatcher(str3));
}


public function addFunction(server:InputFunc ifs) returns int|error{
  json nips = <json> ifs;
  Nip nip = check nips.cloneWithType();
  return nip.x + nip.y;
}

public function subFunction(server:InputFunc ifs) returns int|error{
  json nips = <json> ifs;
  Nip nip = check nips.cloneWithType();
  return nip.x - nip.y;
}