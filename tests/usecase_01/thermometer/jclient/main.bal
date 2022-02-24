import asus/json_rpc.'client;
import ballerina/io;
import asus/json_rpc.types;

public function main() {
    'client:UDPClient udpClient = new("localhost",8080);
    udpClient.register();

    udpClient.sendRequest("convirt", {"z": 80}, function (types:Response|types:Error? u) returns () {
        io:println("1 : ", u);
    });

    udpClient.sendRequest("print", {"z": 80}, function (types:Response|types:Error? u) returns () {
        io:println("2 : ", u);
    });

    udpClient.sendRequest("convirt", {"zs": 80}, function (types:Response|types:Error? u) returns () {
        io:println("3 : ", u);
    });

    udpClient.sendRequest("convirt", {"s": 180}, function (types:Response|types:Error? u) returns () {
        io:println("4 : ", u);
    });

    udpClient.sendRequest("convirt", {"z": 180}, function (types:Response|types:Error? u) returns () {
        io:println("5 : ", u);
    });

    udpClient.closeClient();
}