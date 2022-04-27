import madusanka/json_rpc.'client;
import madusanka/json_rpc.types;
import ballerina/io;

public function main() {
    types:WSConfig uc ={
        host: "localhost",
        port: 3000,
        security: {
            secureSocket: {
                cert: "../resources/certificate.crt"
            }
        }
    };

    'client:Client cl = new(uc);
    cl.register();
    Employ emp = <Employ>cl.getService(new Employ());

    emp.getLeader();

    emp.getNames();

    emp.getTotalSalary(function (int i) returns () {
       io:println("Total salary is ", i); 
    });

    emp.getSalary("Jones", "Welsh");

    cl.close(function(){
        io:println("Client has been closed...");
    });
}


class Employ{
    *'client:JRPCService;
    
    function init() {
        self.clientService = new();
    }

    public function getLeader() {io:println("A");
        self.clientService.sendRequest("lead",(), function (types:Response|types:Error? response){
            if response is types:Response{
                io:println("Leader is ", response.result);
            }
        });
    }

    public function getSalary(string f, string l) {io:println("D");
        self.clientService.sendRequest("salary",{first:100, last:l}, function (types:Response|types:Error? response){
            if response is types:Response{
                io:println("Salary is ", response.result);
            }else {
                io:println("Error occured...");
            }
        });
    }

    public function getNames() {io:println("B");
        self.clientService.sendRequest("list_fnames",(), function (types:Response|types:Error? response){
            if response is types:Response{
                io:println("Names ", response.result);
            }
        });
    }

    public function getTotalSalary(function (int total) callback) {io:println("C");
        self.clientService.sendRequest("total", (), function(types:Response|types:Error? response){
            if response is types:Response{
                callback(<int> response.result);
            }
        });
    }
    

}