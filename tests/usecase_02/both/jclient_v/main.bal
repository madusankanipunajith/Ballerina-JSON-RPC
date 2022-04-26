import asus/json_rpc.'client;
import ballerina/io;
import asus/json_rpc.types;

public function main() {
    types:WSConfig wc ={
        host: "localhost",
        port: 3000
    };
    'client:Client cl = new(wc);
    cl.register();
    
    Calculator calculator = <Calculator>cl.getService(new Calculator());
    Thermometer thermometer = <Thermometer>cl.getService(new Thermometer());
    
    calculator.add({"x":100,"y":290});
    calculator.sub(200);
    thermometer.convert({"z":100});

    cl.close(function(){
        io:println("close the client...");
    }); 
}

class Calculator {
    *'client:JRPCService;

    private string CALC = "calculator";

    public function init() {
        self.clientService = new();
    }

    public function add(anydata params) {
        self.clientService.sendRequest(self.CALC+"/add", params, function (types:Response|types:Error? u) returns () {
            io:println(u);
        });
    }

    public function sub(anydata params) {
        self.clientService.sendRequest(self.CALC+"/sub", params, function (types:Response|types:Error? u) returns () {
           io:println(u); 
        });
    }
}

class Thermometer {
    *'client:JRPCService;

    private string THERMO = "thermometer";

    public function init() {
        self.clientService = new();
    }

    public function convert(anydata params) {
        self.clientService.sendRequest(self.THERMO+"/convirt", params, function (types:Response|types:Error? u) returns () {
           io:println(u); 
        });
    }
}
