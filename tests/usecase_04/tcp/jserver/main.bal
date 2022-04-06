import ballerina/io;
import ballerina/log;
import ballerina/tcp;
import json_rpc.server;
import json_rpc.types;

type P record {
    int x;
};

service on new tcp:Listener(3000) {

    remote function onConnect(tcp:Caller caller) returns tcp:ConnectionService {
        io:println("Client connected to echo server: ", caller.remotePort);
        return new TCPService();
    }
}

service class TCPService {
    *tcp:ConnectionService;
    remote function onBytes(tcp:Caller caller, readonly & byte[] data) returns tcp:Error? {
        svr.sendResponse(caller,data);
    }

    remote function onError(tcp:Error err) {
        log:printError("An error occurred", 'error = err);
    }

    remote function onClose() {
        io:println("Client left");
    }
}

server:Server svr = new(new Calculator());

class Calculator{
    *server:JRPCService;

    function init() {
        self.methods = new CM();
    }

    public isolated function name() returns string {
        return "calc";
    }
}

class CM{
    *server:JRPCMethods;

    public function display(types:InputParams params) {
        P p = <P> params;
        io:println(p.x);
    }
    public isolated function getMethods() returns types:Methods {
        return {
            "display" : self.display
        };
    }
}