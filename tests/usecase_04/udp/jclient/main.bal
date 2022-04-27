import madusanka/json_rpc.'client;
import madusanka/json_rpc.types;
import ballerina/io;

public function main() {
    types:UDPConfig wc ={
        host: "localhost",
        port: 3000
    };

    'client:Client cl = new(wc);
    cl.register();
    service_01 service01 = <service_01>cl.getService(new service_01()); 

    service01.setName("Nipunajith");
    service01.getName(function (string name) returns () {
       io:println("name is ",name); 
    });
    service01.getObject(function (json obj) returns () {
       io:println(obj); 
    });

    cl.close(function(){
        io:println("Close the client...");
    }); 
}

class service_01 {
    *'client:JRPCService;

    function init() {
        self.clientService = new();
    }

    public function setName(string name) {
        self.clientService.sendRequest("name",{"name": name} ,function (types:Response|types:Error? response){
            if response is types:Response {
                io:println("event has been ", response.result);
            }else {
                io:println("something went wrong");
            }
        });
    }

    public function getName(function (string name) callback) {
        self.clientService.sendRequest("get",{"attribute":"name"},function(types:Response|types:Error? response){
            if response is types:Response{
                callback(<string>response.result);
            }
        });
    }

    public function getObject(function (json obj) callback) {
        self.clientService.sendRequest("get",(),function(types:Response|types:Error? response){
            if response is types:Response{
                callback(<json>response.result);
            }
        });
    }

}