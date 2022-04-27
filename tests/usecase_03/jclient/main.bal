import madusanka/json_rpc.'client;
import madusanka/json_rpc.types;
import ballerina/io;

public function main() {
    types:WSConfig wc ={
        host: "localhost",
        port: 3000
    };
    'client:Client jcl = new(wc);
    jcl.register(); 

    EmpClient cl = <EmpClient> jcl.getService(new EmpClient());

    cl.getSalary({"name": "Madusanka"});
    cl.increseSalary({"name": "Nadeeshaan", "salary": 500},function (types:Response|types:Error? u) returns () {
       io:println(u); 
    });
    cl.getSalary({"name": "Nadeeshaan"});
    cl.resetSalary();
    cl.getSalary({"name": "Nadeeshaan"});

    jcl.close(function (){
        io:println("close the client...");
    });
}

class EmpClient {
    *'client:JRPCService;

    function init() {
        self.clientService = new();
    }

    // reusable method
    public function increseSalary(anydata params, function (types:Response|types:Error? out) response) {
        self.clientService.sendRequest("increase",params,function (types:Response|types:Error? u) returns () {
           response(u); 
        });
    }

    // reusable method
    public function getSalary(anydata params) {
        self.clientService.sendRequest("salary",params,function (types:Response|types:Error? u) returns () {
           io:println(u); 
        });
    }

    // reusable method
    public function resetSalary() {
        self.clientService.sendNotification("reset",());
    }
}
