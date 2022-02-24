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

service / on new websocket:Listener(3000) {
    resource function get .() returns websocket:Service|websocket:Error {
        return new WsService();
    }
}

CTServer calculatorServer = new ();

service class WsService {
    *websocket:Service;
    remote function onBinaryMessage(websocket:Caller caller, byte[] data) returns websocket:Error? {
        io:println("\nmessage: ", string:fromBytes(data));

        @strand {
            thread: "any"
        }
        worker T {
            calculatorServer.send(caller, data);
        }
    }

    remote function onClose(websocket:Caller caller, int statusCode, string reason) {
        io:println(string `Client closed connection with ${statusCode} because of ${reason}`);
    }
}

// use case of the server
class CTServer {

    server:Server serv;
    function init() {
        self.serv = new ([new Calculator(),new Thermometer()]);
    }

    public function send(websocket:Caller caller, byte[] message) {
        return self.serv.sendResponse(caller, message);
    }
}

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

class Thermometer {
    *server:JRPCService;

    function init() {
        TherMethods tmethods = new ();
        self.methods = tmethods;
    }

    public isolated function name() returns string {
        return "thermometer";
    }
}

class TherMethods {
    *server:JRPCMethods;

    isolated function convirtFunction(types:InputParams ifs) returns error|float {
        Temp temp = check ifs.cloneWithType();
        float ans = (temp.z * 9 / 5) + 32;
        return ans;
    }

    isolated function printFunction(types:InputParams ifs) {
        Temp temp = checkpanic ifs.cloneWithType();
        io:println("Hello madusanka : ", temp.z);
    }

    public isolated function getMethods() returns types:Methods {
        return {"convirt": self.convirtFunction, "print": self.printFunction};
    }
}
