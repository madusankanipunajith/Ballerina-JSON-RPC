import json_rpc.'client;
import json_rpc.types;
import ballerina/io;

public function main() {
    types:TCPConfig uc ={
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

    cl.close();
}

class Employ{
    *'client:JRPCService;
    
    function init() {
        self.clientService = new();
    }

    public function getLeader() {
        self.clientService.sendRequest("lead",(), function (types:Response|types:Error? response){
            if response is types:Response{
                io:println("Leader is ", response.result);
            }
        });
    }

    public function getSalary(string f, string l) {
        self.clientService.sendRequest("salary",{first:100, last:l}, function (types:Response|types:Error? response){
            if response is types:Response{
                io:println("Salary is ", response.result);
            }else {
                io:println("Error occured...");
            }
        });
    }

    public function getNames() {
        self.clientService.sendRequest("list_fnames",(), function (types:Response|types:Error? response){
            if response is types:Response{
                io:println("Names ", response.result);
            }
        });
    }

    public function getTotalSalary(function (int total) callback) {
        self.clientService.sendRequest("total", (), function(types:Response|types:Error? response){
            if response is types:Response{
                callback(<int> response.result);
            }
        });
    }
    

}
