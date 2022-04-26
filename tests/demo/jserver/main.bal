import ballerina/websocket;
import ballerina/io;
import asus/json_rpc.server;
import asus/json_rpc.types;

type R record {
    int x;
    int y;
};
 
service / on new websocket:Listener(3000) {
    resource function get .() returns websocket:Service|websocket:Error {
        return new WsService();
    }
}

service class WsService {
    *websocket:Service;
    remote function onBinaryMessage(websocket:Caller caller, byte[] data) returns websocket:Error? {
       svr.sendResponse(caller,data);
    }

    remote function onClose(websocket:Caller caller, int statusCode, string reason) {
        io:println(string `Client closed connection with ${statusCode} because of ${reason}`);
    }
}

server:Server svr = new(new Calculator());

public class Calculator {
    *server:JRPCService;

    function init() {
        self.methods = new CM();
    }

    public isolated function name() returns string {
        return "calc";
    }
}

public class CM {
    *server:JRPCMethods;

    public function add(types:InputParams params) returns error|int {
        R r = check params.cloneWithType();
        return r.x + r.y;
    }

    public isolated function getMethods() returns types:Methods {
        return {
            "add": self.add
        };
    }
}




























// import ballerina/websocket;
// import ballerina/io;
// import json_rpc.server;
// import json_rpc.types;

// type R record {
//     int x;
//     int y;
// };

// service / on new websocket:Listener(3000) {
//     resource function get .() returns websocket:Service|websocket:Error {
//         return new WsService();
//     }
// }

// service class WsService {
//     *websocket:Service;
//     remote function onBinaryMessage(websocket:Caller caller, byte[] data) returns websocket:Error? {
//        worker T {
//            svr.sendResponse(caller,data);
//        }
//     }

//     remote function onClose(websocket:Caller caller, int statusCode, string reason) {
//         io:println(string `Client closed connection with ${statusCode} because of ${reason}`);
//     }
// }

// server:Server svr = new(new Calculator());
// public class Calculator {
//     *server:JRPCService;

//     function init() {
//         self.methods = new CM();
//     }

//     public isolated function name() returns string {
//         return "calc";
//     }
// }

// public class CM {
//     *server:JRPCMethods;

//     public function add(types:InputParams params) returns int|error{
//         R r = check params.cloneWithType();
//         return r.x + r.y;
//     }

//     public function sub(types:InputParams params) returns int|error{
//         R r = check params.cloneWithType();
//         return r.x - r.y;
//     }

//     public function mult(types:InputParams params) returns int|error{
//         R r = check params.cloneWithType();
//         return r.x * r.y;
//     }

//     public function div(types:InputParams params) returns string|float|error{
//         R r = check params.cloneWithType();
//         if r.y == 0 {
//             return "error: can't divide a number by zero";    
//         }

//         return <float>(r.x / r.y);
//     }

//     public isolated function getMethods() returns types:Methods{    
//         return {
//             "add": self.add,
//             "sub": self.sub,
//             "div": self.div,
//             "mult": self.mult
//         };
//     }
// }