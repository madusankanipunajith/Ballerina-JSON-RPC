import asus/json_rpc.'client;
import ballerina/io;
import asus/json_rpc.types;

public function main() {
    types:WSConfig wc ={
        host: "localhost",
        port: 3000
    };

    'client:Client cl = new(wc);
    //cl.register();
    Calculator calc = <Calculator> cl.getService(new Calculator());
    
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

    calc.convert({"z": 100});

    cl.close(function(){
        io:println("close the client...");
    });
}

class Calculator {
    *'client:JRPCService;

    function init() {
        self.clientService = new();
    }

    // reusable method
    public function add(anydata params, function (types:Response|types:Error? out) response) {
        self.clientService.sendRequest("calculator/add",params,function (types:Response|types:Error? u) returns () {
           response(u); 
        });
    }

    // reusable method
    public function sub(anydata params) {
        self.clientService.sendRequest("calculator/sub",params,function (types:Response|types:Error? u) returns () {
           io:println(u); 
        });
    }

    // reusable method
    public function convert(anydata params) {
        self.clientService.sendRequest("thermometer/convirt",params,function (types:Response|types:Error? u) returns () {
           io:println(u); 
        });
    }
}
