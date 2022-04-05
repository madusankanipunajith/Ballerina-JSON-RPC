// import json_rpc.'client;
// import ballerina/io;
// import json_rpc.types;

// public function main() {
//     'client:WSClient cl = new("localhost",3000);
//     cl.register();


// }

// public function main() {
//     CalculatorClient calc = new("localhost",3000);
//     calc.starts();

//     calc.add({"x":100, "y": 80}, function (types:Response|types:Error? u) returns () {
//         io:println(u);
//     });

//     calc.add({"x":1000, "y": 80}, function (types:Response|types:Error? u) returns () {
//         io:println(u);
//     });

//     calc.add({"x":1400, "y": 80}, function (types:Response|types:Error? u) returns () {
//         io:println(u);
//     });

//     calc.sub({"x":100,"y":90});

//     calc.sub(100);

//     calc.close();
// }

// class CalculatorClient {
//     private 'client:WSClient wsClient;

//     public function init(string host, int port) {
//         self.wsClient = new(host, port);
//     }

//     public function starts() {
//         self.wsClient.register();
//     }

//     public function close() {
//         self.wsClient.closeClient();
//     }

//     // reusable method
//     public function add(anydata params, function (types:Response|types:Error? out) response) {
//         self.wsClient.sendRequest("add",params,function (types:Response|types:Error? u) returns () {
//            response(u); 
//         });
//     }

//     // reusable method
//     public function sub(anydata params) {
//         self.wsClient.sendRequest("sub",params,function (types:Response|types:Error? u) returns () {
//            io:println(u); 
//         });
//     }
// }


