import json_rpc.'types;
import json_rpc.'client;
import ballerina/io;

public function main() returns error? {

    'client:Client cl = new ("localhost", 9000, 'client:TCP, new CalculatorMethod());
    CalculatorMethod calculatorMethod = <CalculatorMethod>cl.ops();
    
    calculatorMethod.addFunction(125, {"x": 10, "y": 20}, function(types:JRPCResponse t) returns () {
        io:println(t);
    });

    calculatorMethod.subFunction(189, {"x": 200, "y": 100}, function (types:JRPCResponse t) returns () {
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
            method: "add"
        };

        types:JRPCResponse sendMessage = self.clientService.sendMessage(r);
        callback(sendMessage);
    }

    public function subFunction(int id, json params, function ('types:JRPCResponse response) callback) {
        'types:Request r = {
            id: id,
            params: params,
            method: "sub"
        };

        types:JRPCResponse sendMessage = self.clientService.sendMessage(r);
        callback(sendMessage);
    }

    public function notFunction(json params) {
        'types:Notification n = {
            params: params,
            method: "mult"
        };

        self.clientService.sendNotification(n);
    }
}

