import asus/json_rpc.'types;
import asus/json_rpc.'client;
import ballerina/io;

public function main() returns error? {

    'types:TCPConfig tcpConfig={
       tcpRemoteHost: "localhost",
       tcpRemotePort: 9000
    };
    
    'client:Client cl = new (tcpConfig,[new CalculatorMethod(), new ThermoMethod()]);
    CalculatorMethod calculatorMethod = <CalculatorMethod> check cl.ops(CalculatorMethod);
    ThermoMethod thermoMethod = <ThermoMethod> check cl.ops(ThermoMethod);
    
    calculatorMethod.addFunction(125, 100, function(types:JRPCResponse t) returns () {
        io:println(t);
    });

    calculatorMethod.subFunction(189, {"x": 200, "y": 100}, function (types:JRPCResponse t) returns () {
       io:println(t); 
    });

    thermoMethod.printFunction(140, {"z": 100.60}, function (types:JRPCResponse t) returns () {
       io:println(t); 
    });

    cl.closeClient();

}

class CalculatorMethod {
    *'client:JRPCClientMethods;

    function init() {
        self.clientService = new();
    }

    public function addFunction(int id, json params, function ('types:JRPCResponse response) callback) {
        'types:Request r = {
            id: id,
            params: params,
            method: "calculator/add"
        };

        types:JRPCResponse sendMessage = self.clientService.sendMessage(r);
        callback(sendMessage);
    }

    public function subFunction(int id, json params, function ('types:JRPCResponse response) callback) {
        'types:Request r = {
            id: id,
            params: params,
            method: "calculator/sub"
        };

        types:JRPCResponse sendMessage = self.clientService.sendMessage(r);
        callback(sendMessage);
    }

    public function notFunction(json params) {
        'types:Notification n = {
            params: params,
            method: "calculator/mult"
        };

        self.clientService.sendNotification(n);
    }
}


class ThermoMethod{
    *'client:JRPCClientMethods;

    function init() {
        self.clientService = new();
    }

    public function printFunction(int id, json params, function ('types:JRPCResponse response) callback) {
        'types:Request r = {
            id: id,
            params: params,
            method: "thermometer/print"
        };

        types:JRPCResponse sendMessage = self.clientService.sendMessage(r);
        callback(sendMessage);
    }
}