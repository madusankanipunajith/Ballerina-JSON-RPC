import json_rpc.'client;
import ballerina/io;
import json_rpc.types;

// public function main() {
//     'client:WSClient wsClient = new("localhost",3000);
//     wsClient.register();


//     wsClient.sendRequest("add", {"x":100, "y": 80}, function (types:Response|types:Error u) returns () {
//         io:println("1 : ", u);
//     });

//     wsClient.sendRequest("sub", {"x":100, "y": 80}, function (types:Response|types:Error u) returns () {
//         io:println("2 : ", u);
//     });
    
//     wsClient.sendRequest("sub", 100, function (types:Response|types:Error u) returns () {
//         io:println("3 : ", u);
//     });


//     wsClient.sendRequestBatch([{method: "add",params: {"x":100, "y": 80}}],function (types:BatchJRPCOutput|types:Error u) returns () {
//         io:println("4 : ", u);
//     });
    
//     wsClient.sendRequestBatch([{method: "sub",params: {"x":100, "y": 80},notification: true},{method: "sub", params: {"x":100, "y": 80}}],function (types:BatchJRPCOutput|types:Error u) returns () {
//         io:println("5 : ", u);
//     });

//     wsClient.sendRequestBatch([{method: "div", params: {"x":100, "yz": 80}}],function (types:BatchJRPCOutput|types:Error u) returns () {
//         io:println("6 : ", u);
//     });
    
//     wsClient.sendRequestBatch([{method: "sub",params: {"x":100, "y": 80},notification: true},{method: "sub", params: {"x":100, "y": 80}}],function (types:BatchJRPCOutput|types:Error u) returns () {
//         io:println("7 : ", u);
//     });

//     wsClient.sendRequestBatch([{method: "add",params: {"x":100, "y": 80}},{method: "sub", params: {"x":100, "y": 80}}],function (types:BatchJRPCOutput|types:Error u) returns () {
//         io:println("8 : ", u);
//     });
    
//     wsClient.sendRequestBatch([{method: "sub",params: {"x":100, "y": 80},notification: true},{method: "sub", params: {"x":100, "y": 80}}],function (types:BatchJRPCOutput|types:Error u) returns () {
//         io:println("9 : ", u);
//     });

//     wsClient.closeClient();   
    
// }



public function main() {
    CalculatorClient calc = new("localhost",3000);
    calc.starts();

    calc.add({"x":100, "y": 80}, function (types:Response|types:Error? u) returns () {
        io:println(u);
    });

    calc.add({"x":1000, "y": 80}, function (types:Response|types:Error? u) returns () {
        io:println(u);
    });

    calc.add({"x":1400, "y": 80}, function (types:Response|types:Error? u) returns () {
        io:println(u);
    });

    calc.sub({"x":100,"y":90});

    calc.sub(100);

    calc.close();
}

class CalculatorClient {
    private 'client:WSClient wsClient;

    public function init(string host, int port) {
        self.wsClient = new(host, port);
    }

    public function starts() {
        self.wsClient.register();
    }

    public function close() {
        self.wsClient.closeClient();
    }

    // reusable method
    public function add(anydata params, function (types:Response|types:Error? out) response) {
        self.wsClient.sendRequest("add",params,function (types:Response|types:Error? u) returns () {
           response(u); 
        });
    }

    // reusable method
    public function sub(anydata params) {
        self.wsClient.sendRequest("sub",params,function (types:Response|types:Error? u) returns () {
           io:println(u); 
        });
    }
}


