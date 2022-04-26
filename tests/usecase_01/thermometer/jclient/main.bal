import asus/json_rpc.'client;
import ballerina/io;
import asus/json_rpc.types;

public function main() {
    types:UDPConfig wc ={
        host: "localhost",
        port: 8080
    };
   'client:Client cl = new(wc);
    cl.register();

    Thermometer thermo = cl.getService(new Thermometer());

    thermo.clientService.sendRequest("convirt", {"z": 80}, function (types:Response|types:Error? u) returns () {
        io:println("1 : ", u);
    });

    thermo.clientService.sendRequest("print", {"z": 80}, function (types:Response|types:Error? u) returns () {
        io:println("2 : ", u);
    });

    thermo.clientService.sendRequest("convirt", {"zs": 80}, function (types:Response|types:Error? u) returns () {
        io:println("3 : ", u);
    });

    thermo.clientService.sendRequest("convirt", {"s": 180}, function (types:Response|types:Error? u) returns () {
        io:println("4 : ", u);
    });

    thermo.clientService.sendRequest("convirt", {"z": 180}, function (types:Response|types:Error? u) returns () {
        io:println("5 : ", u);
    });

    cl.close(function (){
        io:println("Client has been disconnected ....");
    });
}

public class Thermometer {
    *'client:JRPCService;

    function init() {
        self.clientService = new();
    }

}