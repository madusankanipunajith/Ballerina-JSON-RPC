import ballerina/udp;
import ballerina/io;
import madusanka/json_rpc.server;
import madusanka/json_rpc.types;

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

service on new udp:Listener(3000) {

    remote function onDatagram(udp:Caller caller , readonly & udp:Datagram datagram) returns udp:Error? {
        io:println("Received by listener: ", string:fromBytes(datagram.data));
        svr.sendResponse(caller,datagram.data);
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