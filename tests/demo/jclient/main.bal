import asus/json_rpc.'client;
import asus/json_rpc.types;
import ballerina/io;

public function main() {
    types:WSConfig  wc = {
        host: "localhost",
        port: 3000
    };

    'client:Client cl = new(wc);
    cl.register();

    Calculator calc = <Calculator>cl.getService(new Calculator());
    calc.add(10,20);
    calc.sub(100,20);
    calc.multiply(30,10,function (int i) returns () {
        io:println("Answer is : ", i);    
    });

    cl.close();
}

public class Calculator {
    *'client:JRPCService;

    function init() {
        self.clientService = new();
    }

    public function add(int a, int b) {
        self.clientService.sendRequest("add", {x:a, y:b}, function (types:Response|types:Error? u) returns () {
           io:println(u); 
        });
    }

    public function sub(int a, int b) {
        self.clientService.sendRequest("sub", 100, function (types:Response|types:Error? u) returns () {
           io:println(u); 
        });
    }

    public function multiply(int a, int b, function (int answer) callback) {
        self.clientService.sendRequest("mult", {x:a, z:b}, function (types:Response|types:Error? u) returns () {
           if u is types:Response {
               callback(<int>u.result);
           }else{
               io:println(u);
           } 
        });
    }

    // define the division....
}

