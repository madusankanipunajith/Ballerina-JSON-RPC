import ballerina/websocket;
import ballerina/io;
import asus/json_rpc.server;
import asus/json_rpc.types;

type R record {|
    string school;
|};

type T record {|
    string attribute;
|};

map<json> object1 = {
    name: "Madusanka",
    age: 25,
    school: "Ananda college",
    university: "UCSC"
};

map<json> object2 = {
    name: "Kasun",
    age: 20,
    school: "Ananda college",
    university: "UOM"
};

server:Server svr = new (new Service_01());

service / on new websocket:Listener(3000) {
    resource function get .() returns websocket:Service|websocket:Error {
        return new WsService();
    }
}

service class WsService {
    *websocket:Service;
    remote function onBinaryMessage(websocket:Caller caller, byte[] data) returns websocket:Error? {
        io:println("\nmessage: ", string:fromBytes(data));
        svr.sendResponse(caller, data);
    }

    remote function onClose(websocket:Caller caller, int statusCode, string reason) {
        io:println(string `Client closed connection with ${statusCode} because of ${reason}`);
    }
}

class Service_01 {
    *server:JRPCService;

    function init() {
        self.methods = new Method_s01();
    }

    public isolated function name() returns string {
        return "s1";
    }
}

class Method_s01 {
    *server:JRPCMethods;

    public function name(types:InputParams ifs) returns error? {
        json obj = {
            name: ""
        };
        obj = check ifs.cloneWithType();
        map<json> obj_01 = <map<json>>obj;
        string name = <string>obj_01["name"];

        lock {
            object1["name"] = name;
        }
    }

    public function school(types:InputParams ifs) returns error? {
        R rec = check ifs.cloneWithType();
        lock {
            object1["school"] = rec.school;
        }
    }

    public function get(types:InputParams ifs) returns json|string|error {
        if ifs === () {
            return object1;
        } else {
            T rec = check ifs.cloneWithType();
            string jsonResult = object1[rec.attribute].toString();
            return jsonResult;
        }
    }

    public isolated function getMethods() returns types:Methods {
        return {
                "name": self.name,
                "school": self.school,
                "get": self.get
            };
    }
}
