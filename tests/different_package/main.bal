// import asus/json_rpc.server;
// import asus/json_rpc.'types;
// import ballerina/io;

// string str = "{\"jsonrpc\":\"2.0\",\"method\":\"add\",\"params\":{\"x\":89, \"y\":100},\"id\":10}";
// string str2 = "{\"foo\": \"boo\"}";
// string str3 = "[{\"jsonrpc\":\"2.0\",\"method\":\"add\",\"params\":{\"x\":89, \"y\":100},\"id\":10}, {\"jsonrpc\":\"2.0\",\"method\":\"sub\",\"params\":{\"x\":89, \"y\":100},\"id\":10}]";
// string str4 = "{\"jsonrpc\":\"2.0\",\"method\":\"mult\",\"params\":[10,20,30],\"id\":10}";
// string str5 = "{\"jsonrpc\":\"2.0\",\"method\":\"print\",\"id\":10}";
// string str60 = "{\"jsonrpc\":\"2.0\",\"method\":\"add\",\"params\":100,\"id\":10}";
// string str6 = "[]";
// string str7 = "{\"jsonrpc\":\"2.0\",\"method\":\"thermometer/convirt\",\"params\":{\"z\":100},\"id\":10}";
// string str8 = "{\"jsonrpc\":\"2.0\",\"method\":\"thermometer/print\",\"params\":{\"z\":100},\"id\":10}";

// type Nip record {|
//     int x;
//     int y;
// |};

// type Temp record {
//   float z;
// };


// public function main() {
   
//     Calculator calc = new();
//     Thermometer termo = new();
//     server:Server s1 = new([calc, termo]);
//     io:println(s1.runner(str8));

// }

// class Calculator{
//   *server:JRPCService;

//     function init() {
//       CalcMethods cmethods = new();
//       self.methods = cmethods;
//     }

//     public isolated function name() returns string|error {
//         return "calculator";
//     }

// }

// class Thermometer {
//   *server:JRPCService;

//     function init() {
//       TherMethods tmethods = new();
//       self.methods = tmethods;
//     }

//     public isolated function name() returns string|error {
//         return "thermometer";
//     }
// }


// isolated class CalcMethods {
//   *'types:JRPCMethods;

//     isolated function addFunction(server:Input ifs) returns int|error{
//       Nip nip = check ifs.cloneWithType();
//       return nip.x + nip.y;
//     }

//     isolated function subFunction(server:Input ifs) returns int|error{
//       Nip nip = check ifs.cloneWithType();
//       return nip.x - nip.y;
//     }
    
//     public isolated function getMethods() returns 'types:Methods{

//         'types:Methods meth={
//           "add": self.addFunction,
//           "sub": self.subFunction
//         };

//         return meth;
//     }    

// }

// isolated class TherMethods {
//   *'types:JRPCMethods;

//     isolated function convirtFunction(server:Input ifs) returns error|float{
//       Temp temp = check ifs.cloneWithType();
//       float ans = (temp.z*9/5) + 32;
//       return ans;
//     }

//     isolated function printFunction(server:Input ifs) {
//       Temp temp = checkpanic ifs.cloneWithType();
//       io:println("Hello madusanka : ", temp.z);
//     }

//     public isolated function getMethods() returns types:Methods {
//         return {"convirt":self.convirtFunction, "print":self.printFunction};
//     }
// }

import ballerina/io;
import ballerina/log;
import ballerina/tcp;
//import ballerina/lang.runtime;
service on new tcp:Listener(9000) {

    remote function onConnect(tcp:Caller caller)
                              returns tcp:ConnectionService {
        io:println("Client connected to echo server: ", caller.remotePort);
        return new EchoService();
    }
}


service class EchoService {
    *tcp:ConnectionService;
    
    remote function onBytes(tcp:Caller caller, readonly & byte[] data) 
        returns tcp:Error? {
        io:println("Echo: ", string:fromBytes(data));

        string value = checkpanic string:fromBytes(data);
        string answer = value;

        // if value is "Hi" {
            
        //     io:println("Hi was recieved by server");
        //     runtime:sleep(6);
        //     answer = "executed after 6 seconds";
        
        // }else{
            
        //     io:println("Bye was recieved by server");
        //     runtime:sleep(2);
        //     answer = "executed after 2 seconds";
        
        // }

        return caller->writeBytes(answer.toBytes());
    }

    remote function onError(tcp:Error err) {
        log:printError("An error occurred", 'error = err);
    }

    remote function onClose() {
        io:println("Client left");
    }
}