import json_rpc.'client;
import ballerina/io;
import json_rpc.types;

public function main() {
    'client:WSClient wsClient = new("ws://localhost:3000");
    wsClient.register();

    wsClient.sendRequest("add", {"x":100, "y": 80}, function (types:Response|types:Error u) returns () {
        io:println("1 : ", u);
    });

    wsClient.sendRequest("sub", {"x":100, "y": 80}, function (types:Response|types:Error u) returns () {
        io:println("2 : ", u);
    });

    wsClient.sendRequest("sub", 100, function (types:Response|types:Error u) returns () {
        io:println("3 : ", u);
    });

    wsClient.sendRequestBatch([{method: "add",params: {"x":100, "y": 80}},{method: "sub", params: {"x":100, "y": 80}}],function ('client:BatchJRPCOutput|types:Error u) returns () {
        io:println("4 : ", u);
    });

    wsClient.sendRequestBatch([{method: "sub",params: {"x":100, "y": 80},notification: true},{method: "sub", params: {"x":100, "y": 80}}],function ('client:BatchJRPCOutput|types:Error u) returns () {
        io:println("5 : ", u);
    });


    wsClient.closeClient();   
    
}










// public function main() {
//     CalculatorClient calc = new("ws://localhost:3000");
//     calc.starts();

//     calc.add("add", {"x":100, "y": 80}, function (types:Response|types:Error u) returns () {
//         io:println(u);
//     });

//     calc.close();
// }

class CalculatorClient {
    private 'client:WSClient wsClient;

    public function init(string path) {
        self.wsClient = new(path);
    }

    public function starts() {
        self.wsClient.register();
    }

    public function close() {
        self.wsClient.closeClient();
    }

    public function add(string method, anydata params, function (types:Response|types:Error out) response) {
        self.wsClient.sendRequest(method,params,function (types:Response|types:Error u) returns () {
           response(u); 
        });
    }
}