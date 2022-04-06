import ballerina/io;
import json_rpc.'client;
import json_rpc.types;

public function main() {
    types:TCPConfig tc ={
        host: "localhost",
        port: 3000
    };

    'client:Client cl = new(tc);
    Calculator calc =  <Calculator>cl.getService(new Calculator());
    calc.display(100);
}

class Calculator{
    *'client:JRPCService;

    function init() {
        self.clientService = new();
    }

    public function display(int params) {
        self.clientService.sendRequest("display", {x:params}, function (types:Response|types:Error? u) returns (){
            if u is types:Response {
                io:println(u.result);
            }
        });
    }
}
