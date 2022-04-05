
import ballerina/io;
import ballerina/udp;
import json_rpc.server;
import json_rpc.types;

type Nip record {
    int x;
    int y;
};
service on new udp:Listener(8080) {

    remote function onDatagram(udp:Caller caller , readonly & udp:Datagram datagram) returns udp:Error? {
        io:println("Received by listener: ", string:fromBytes(datagram.data));
        s1.sendResponse(caller,datagram.data);
    }

    
}



server:Server s1 = new(new Calculator());







// import ballerina/websocket;
// import ballerina/io;
// import json_rpc.server;
// import json_rpc.types;

// type T record {
//     int x;
//     int y;
// };

// service / on new websocket:Listener(5000) {
//     resource function get . () returns websocket:Service|websocket:Error{
//         return new WsService();
//     }
// }

// service class WsService {
//     *websocket:Service;
//     remote function onBinaryMessage(websocket:Caller caller, byte[] data) returns websocket:Error? {
//         io:println("\nmessage: ", string:fromBytes(data));
//     }

//     remote function onClose(websocket:Caller caller, int statusCode, string reason) {
//         io:println(string `Client closed connection with ${statusCode} because of ${reason}`);
//     }
// }

class Calculator {
    *server:JRPCService;

    function init() {
        CalcMethods cmethods = new ();
        self.methods = cmethods;
    }

    public isolated function name() returns string {
        return "calculator";
    }

}

class CalcMethods {
    *server:JRPCMethods;

    isolated function addFunction(types:InputParams ifs) returns int|error {
        Nip nip = check ifs.cloneWithType();
        return nip.x + nip.y;
    }

    isolated function subFunction(types:InputParams ifs) returns int|error {
        Nip nip = check ifs.cloneWithType();
        return nip.x - nip.y;
    }

    isolated function divFunction(types:InputParams ifs) returns float|error{
        Nip nip = check ifs.cloneWithType();
        return <float>nip.x/<float>nip.y;
    }

    public isolated function getMethods() returns 'types:Methods {

        'types:Methods meth = {
        "add": self.addFunction,
        "sub": self.subFunction,
        "div": self.divFunction
        };

        return meth;
    }

}

// WS server side skelton

//import ballerina/websocket;
//import ballerina/io;
// service / on new websocket:Listener(5000) {
//     resource function get . () returns websocket:Service|websocket:Error{
//         return new WsService();
//     }
// }

// service class WsService {
//     *websocket:Service;
//     remote function onBinaryMessage(websocket:Caller caller, byte[] data) returns websocket:Error? {
//         io:println("\nmessage: ", string:fromBytes(data));
//     }

//     remote function onClose(websocket:Caller caller, int statusCode, string reason) {
//         io:println(string `Client closed connection with ${statusCode} because of ${reason}`);
//     }
// }

//TCP Server side skelton

// import ballerina/io;
// import ballerina/log;
// import ballerina/tcp;
// service on new tcp:Listener(3000) {

//     remote function onConnect(tcp:Caller caller) returns tcp:ConnectionService {
//         io:println("Client connected to echo server: ", caller.remotePort);
//         return new TCPService();
//     }
// }

// service class TCPService {
//     *tcp:ConnectionService;
//     remote function onBytes(tcp:Caller caller, readonly & byte[] data) returns tcp:Error? {

//     }

//     remote function onError(tcp:Error err) {
//         log:printError("An error occurred", 'error = err);
//     }

//     remote function onClose() {
//         io:println("Client left");
//     }
// }

//UDP Server side Skelton

// import ballerina/io;
// import ballerina/udp;
// service on new udp:Listener(8080) {

//     remote function onDatagram(readonly & udp:Datagram datagram) 
//         returns udp:Datagram|udp:Error? {
//         io:println("Received by listener: ", string:fromBytes(datagram.data));

//     }
// }