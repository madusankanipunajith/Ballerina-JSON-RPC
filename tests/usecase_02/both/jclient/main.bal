import asus/json_rpc.'client;
import ballerina/io;
import asus/json_rpc.types;

public function main() {
    CTClient cl = new("localhost",3000);
    cl.starts();

    cl.add({"x":100, "y": 80}, function (types:Response|types:Error? u) returns () {
        io:println(u);
    });

    cl.add({"x":1000, "y": 80}, function (types:Response|types:Error? u) returns () {
        io:println(u);
    });

    cl.add({"x":1400, "y": 80}, function (types:Response|types:Error? u) returns () {
        io:println(u);
    });

    cl.sub({"x":100,"y":90});

    cl.convert({"z": 100});

    cl.close();
}

class CTClient {
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
        self.wsClient.sendRequest("calculator/add",params,function (types:Response|types:Error? u) returns () {
           response(u); 
        });
    }

    // reusable method
    public function sub(anydata params) {
        self.wsClient.sendRequest("calculator/sub",params,function (types:Response|types:Error? u) returns () {
           io:println(u); 
        });
    }

    // reusable method
    public function convert(anydata params) {
        self.wsClient.sendRequest("thermometer/convirt",params,function (types:Response|types:Error? u) returns () {
           io:println(u); 
        });
    }
}
