import ballerina/io;
import ballerina/udp;
import madusanka/json_rpc.server;
import madusanka/json_rpc.types;

type Temp record {
    int z;
};

type Temp2 record {
    int z;
};


service on new udp:Listener(8080) {

    remote function onDatagram(udp:Caller caller, readonly & udp:Datagram datagram) returns udp:Datagram|udp:Error? {
        io:println("Received by listener: ", string:fromBytes(datagram.data));

            server:Server termoServer = new([new Thermometer()]);
            return termoServer.sendResponse(caller,datagram.data);
         
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
        float ans = <float>(temp.z * 9 / 5) + 32;
        return ans;
    }

    isolated function printFunction(types:InputParams ifs) returns error?{
        Temp2 temp2 = check ifs.cloneWithType();
        io:println("Hello madusanka : ", temp2.z);
    }

    public isolated function getMethods() returns types:Methods {
        return {"convirt": self.convirtFunction, "print": self.printFunction};
    }
}
