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
    
    calculator.add({"x":100, "y":30});
    calculator.sub(100);
    calculator.add(2090);
    calculator.sub({"x":460,"y":60});

    cl.close();
}

class Calculator {
    *'client:JRPCService;

    function init() {
        self.clientService = new();
    }

    public function add(anydata params) {
        self.clientService.sendRequest("add", params, function (types:Response|types:Error? u) returns () {
            io:println(u);
        });
    }

    public function sub(anydata params) {
        self.clientService.sendRequest("sub", params, function (types:Response|types:Error? u) returns () {
           io:println(u); 
        });
    }
}
