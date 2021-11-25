import ballerina/io;
import ballerina/tcp;
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
    server:Server madusanka = new();
    server:Server nadeeshan = new();
    madusanka.serverFunction("add", addFunction);
    madusanka.serverFunction("sub", subFunction);
    nadeeshan.serverFunction("sub", subFunction);

    io:println(madusanka.messageCatcher(str));
    io:println(nadeeshan.messageCatcher(str));
    
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


service on new tcp:Listener(3000){
    remote function onConnect(tcp:Caller caller){
        io:println("Client connected to echo server: ", caller.remotePort);
    }
} 

service on new tcp:Listener(4000) {
    remote function onConnect(tcp:Caller caller){
        io:println("Client connected to echo server: ", caller.remotePort);
    }
} 
