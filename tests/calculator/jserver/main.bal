import ballerina/io;
import asus/json_rpc.server;
import asus/json_rpc.types;
import ballerina/websocket;

type Nip record {|
    int x;
    int y;
|};

type Temp record {
    float z;
};

// service on new tcp:Listener(9000) {

//     remote function onConnect(tcp:Caller caller) returns tcp:ConnectionService {
//         io:println("Client connected to echo server: ", caller.remotePort);
//         return new MainTCPService();
//     }
// }

// service class MainTCPService {
//     *tcp:ConnectionService;

//     remote function onBytes(tcp:Caller caller, readonly & byte[] data) returns tcp:Error? {
//         io:println("Echo: ", string:fromBytes(data));

//         // calling the library
//         Calculator calc = new ();
//         server:Server s1 = new ([calc]);
//         string input = checkpanic string:fromBytes(data);
//         any runner = s1.runner(input);
//         io:println(runner);
//         return caller->writeBytes(runner.toString().toBytes());

//     }

//     remote function onError(tcp:Error err) {
//         log:printError("An error occurred", 'error = err);
//     }

//     remote function onClose() {
//         io:println("Client left");
//     }
// }

service / on new websocket:Listener(3000) {
    resource isolated function get .() returns websocket:Service|websocket:Error {
        return new WsService();
    }
}

service class WsService {
    *websocket:Service;

    remote function onBinaryMessage(websocket:Caller caller, byte[] data) returns websocket:Error? {
        io:println("\nmessage: ", string:fromBytes(data));

        //calling the library
        Calculator calc = new ();
        server:Server s1 = new ([calc]);
        string input = checkpanic string:fromBytes(data);
        any runner = s1.runner(input);
        io:println("output: ",runner);
        return caller->writeBinaryMessage(runner.toString().toBytes());
        
    }
}

class Calculator {
    *server:JRPCService;

    function init() {
        CalcMethods cmethods = new ();
        self.methods = cmethods;
    }

    public isolated function name() returns string|error {
        return "calculator";
    }

}

isolated class CalcMethods {
    *server:JRPCMethods;

    isolated function addFunction(server:Input ifs) returns int|error {
        Nip nip = check ifs.cloneWithType();
        return nip.x + nip.y;
    }

    isolated function subFunction(server:Input ifs) returns int|error {
        Nip nip = check ifs.cloneWithType();
        return nip.x - nip.y;
    }

    public isolated function getMethods() returns 'types:Methods {

        'types:Methods meth = {
        "add": self.addFunction,
        "sub": self.subFunction
        };

        return meth;
    }

}

class Thermometer {
    *server:JRPCService;

    function init() {
        TherMethods tmethods = new ();
        self.methods = tmethods;
    }

    public isolated function name() returns string|error {
        return "thermometer";
    }
}

isolated class TherMethods {
    *server:JRPCMethods;

    isolated function convirtFunction(server:Input ifs) returns error|float {
        Temp temp = check ifs.cloneWithType();
        float ans = (temp.z * 9 / 5) + 32;
        return ans;
    }

    isolated function printFunction(server:Input ifs) {
        Temp temp = checkpanic ifs.cloneWithType();
        io:println("Hello madusanka : ", temp.z);
    }

    public isolated function getMethods() returns types:Methods {
        return {"convirt": self.convirtFunction, "print": self.printFunction};
    }
}
