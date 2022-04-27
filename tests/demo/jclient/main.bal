import madusanka/json_rpc.'client;
import ballerina/io;
import madusanka/json_rpc.types;

public function main() {
    types:WSConfig wc ={
        host: "localhost",
        port: 3000
    }; 

    'client:Client cl = new(wc);
    cl.register();

    Calculator calc = <Calculator> cl.getService(new Calculator());
    calc.add(10,20);
    calc.sub(20,5);
    calc.mult(10,3, function (int i) returns () {
        // logic
       io:println("Answer is ", i); 
    });

    cl.close(function(){
        io:println("client has been disconnected...");
    });
}

public class Calculator {
    *'client:JRPCService;

    function init() {
        self.clientService = new();
    }

    public function add(int a, int b) {
        self.clientService.sendRequest("add", {x:a, y:b}, function (types:Response|types:Error? response){
            // logic
            io:println(response);
        });
    }

    public function sub(int a, int b) {
        self.clientService.sendRequest("sub", {x:a, y:b}, function (types:Response|types:Error? response){
            // logic
            io:println(response);
        });
    }

    public function mult(int a, int b, function (int answer) callback) {
        self.clientService.sendRequest("mult", {x:a, y:b}, function (types:Response|types:Error? response){
            if response is types:Response {
                callback(<int> response.result);
            }else{
                io:println("something went wrong..");
            }
        });
    }

    // div
}





























// import asus/json_rpc.'client;
// import asus/json_rpc.types;
// import ballerina/io;

// public function main() {
//     types:WSConfig  wc = {
//         host: "localhost",
//         port: 3000
//     };

//     'client:Client cl = new(wc);
//     cl.register();

//     Calculator calc = <Calculator>cl.getService(new Calculator());
//     calc.add(10,20);
//     calc.sub(100,20);
//     calc.multiply(30,10,function (int i) returns () {
//         io:println("Answer is : ", i);    
//     });

//     cl.close();
// }

// public class Calculator {
//     *'client:JRPCService;

//     function init() {
//         self.clientService = new();
//     }

//     public function add(int a, int b) {
//         self.clientService.sendRequest("add", {x:a, y:b}, function (types:Response|types:Error? u) returns () {
//            io:println(u); 
//         });
//     }

//     public function sub(int a, int b) {
//         self.clientService.sendRequest("sub", 100, function (types:Response|types:Error? u) returns () {
//            io:println(u); 
//         });
//     }

//     public function multiply(int a, int b, function (int answer) callback) {
//         self.clientService.sendRequest("mult", {x:a, z:b}, function (types:Response|types:Error? u) returns () {
//            if u is types:Response {
//                callback(<int>u.result);
//            }else{
//                io:println(u);
//            } 
//         });
//     }

//     // define the division....
// }

