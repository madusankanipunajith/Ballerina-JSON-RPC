import madusanka/json_rpc.'client;
import madusanka/json_rpc.types;
import ballerina/io;

public function main() {
    types:UDPConfig uc ={
        host: "localhost",
        port: 3000
    };

    'client:Client cl = new(uc);
    cl.register();
    Employ emp = <Employ>cl.getService(new Employ());

    emp.getLastName(["Jones","Anne", "Rocky", "Nipuna"]);
    emp.getLeader();
    emp.getNames();

    cl.close(function (){
        io:println("Client has been closed successfully");
    });

    io:println("Async client");
}

class Employ{
    *'client:JRPCService;
    
    function init() {
        self.clientService = new();
    }

    public function getLeader() {
        io:println("B");
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

    public function getLastName(string[] fnames) {
        io:println("A");
        types:BatchInput[] input = [];
        foreach var item in fnames {
            input.push({method: "last", params: {first: item, last: ""}});
        }

        self.clientService.sendRequestBatch(input, function (types:BatchJRPCOutput|types:Error? response){
            if response is types:BatchJRPCOutput{
                io:println("Last names are ", response);
            }else {
                io:println("Error occured...");
            }
        });
    }

    public function getNames() {
        io:println("C");
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
