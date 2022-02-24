import asus/json_rpc.'client;
import asus/json_rpc.types;
import ballerina/io;

public function main() {
    EmpClient cl = new("localhost", 3000);
    cl.starts();

    cl.getSalary({"name": "Madusanka"});
    cl.increseSalary({"name": "Nadeeshaan", "salary": 500},function (types:Response|types:Error? u) returns () {
       io:println(u); 
    });
    cl.getSalary({"name": "Nadeeshaan"});
    cl.resetSalary();
    cl.getSalary({"name": "Nadeeshaan"});

    cl.close();
}

class EmpClient {
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
    public function increseSalary(anydata params, function (types:Response|types:Error? out) response) {
        self.wsClient.sendRequest("increase",params,function (types:Response|types:Error? u) returns () {
           response(u); 
        });
    }

    // reusable method
    public function getSalary(anydata params) {
        self.wsClient.sendRequest("salary",params,function (types:Response|types:Error? u) returns () {
           io:println(u); 
        });
    }

    // reusable method
    public function resetSalary() {
        self.wsClient.sendNotification("reset",());
    }
}
