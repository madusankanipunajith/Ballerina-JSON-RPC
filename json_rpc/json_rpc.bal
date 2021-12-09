// import ballerina/io;
// import json_rpc.server;

// type Nip record {|
//     int x;
//     int y;
// |};

// string str = "{\"jsonrpc\":\"2.0\",\"method\":\"add\",\"params\":{\"x\":89, \"y\":100},\"id\":10}";
// string str2 = "{\"foo\": \"boo\"}";
// string str3 = "[{\"jsonrpc\":\"2.0\",\"method\":\"add\",\"params\":{\"x\":89, \"y\":100},\"id\":10}, {\"jsonrpc\":\"2.0\",\"method\":\"sub\",\"params\":{\"x\":89, \"y\":100},\"id\":10}]";
// string str4 = "{\"jsonrpc\":\"2.0\",\"method\":\"mult\",\"params\":[10,20,30],\"id\":10}";
// string str5 = "{\"jsonrpc\":\"2.0\",\"method\":\"print\",\"id\":10}";
// string str60 = "{\"jsonrpc\":\"2.0\",\"method\":\"add\",\"params\":100,\"id\":10}";
// string str6 = "[]";
// public function main() {
//     server:Server s1 = new();
//     s1.register("add", addFunction);
//     io:println(s1.runner(str3));
// }

// public isolated function addFunction(server:Input ifs) returns int|error{
//   Nip nip = check ifs.cloneWithType();
//   return nip.x + nip.y;
// }

// public isolated function printArray(server:Input fis) {
//   any [] p = <any[]> fis;
//   io:println(p[1]);
// }

import json_rpc.server;
import json_rpc.'type;
//import ballerina/tcp;
import ballerina/io;
//import ballerina/log;

string str = "{\"jsonrpc\":\"2.0\",\"method\":\"add\",\"params\":{\"x\":89, \"y\":100},\"id\":10}";
string str2 = "{\"foo\": \"boo\"}";
string str3 = "[{\"jsonrpc\":\"2.0\",\"method\":\"add\",\"params\":{\"x\":89, \"y\":100},\"id\":10}, {\"jsonrpc\":\"2.0\",\"method\":\"sub\",\"params\":{\"x\":89, \"y\":100},\"id\":10}]";
string str4 = "{\"jsonrpc\":\"2.0\",\"method\":\"mult\",\"params\":[10,20,30],\"id\":10}";
string str5 = "{\"jsonrpc\":\"2.0\",\"method\":\"print\",\"id\":10}";
string str60 = "{\"jsonrpc\":\"2.0\",\"method\":\"add\",\"params\":100,\"id\":10}";
string str6 = "[]";

type Nip record {|
    int x;
    int y;
|};

public function main() {
   
    Calculator calc = new();
    server:Server s1 = new(calc);
    io:println(s1.runner(str3));

}

// service on new tcp:Listener(3001) {

//     remote function onConnect(tcp:Caller caller)
//                               returns tcp:ConnectionService {
//         io:println("Client connected to echo server: ", caller.remotePort);
//         return new EchoService();
//     }
// }

// service class EchoService {
//     *tcp:ConnectionService;
//     remote function onBytes(tcp:Caller caller, readonly & byte[] data) 
//         returns tcp:Error? {
//         io:println("Echo: ", string:fromBytes(data));

//         string str = checkpanic string:fromBytes(data);

//         // library calling
//         Calculator calc = new();
//         server:Server s1 = new(calc);
//         io:println(s1.runner(str));

//         return caller->writeBytes(data);
//     }

//     remote function onError(tcp:Error err) {
//         log:printError("An error occurred", 'error = err);
//     }

//     remote function onClose() {
//         io:println("Client left");
//     }
// }

class Calculator{
  *server:JRPCService;

    function init() {
      CalcMethods cmethods = new();
      self.methods = cmethods;
    }

    public isolated function name() returns string|error {
        return "calculator";
    }

}

class Middleware {
  *server:JRPCService;
  
  function init() {
      CalcMethods cmethods = new();
      self.methods = cmethods; 
    }

    public isolated function name() returns string|error {
        return "";
    }

}

isolated class CalcMethods {
  *'type:JRPCMethods;

    isolated function addFunction(server:Input ifs) returns int|error{
      Nip nip = check ifs.cloneWithType();
      return nip.x + nip.y;
    }
    
    public isolated function getMethods() returns 'type:Methods{

        'type:Methods meth={
          "add": self.addFunction
        };

        return meth;
    }    

}



