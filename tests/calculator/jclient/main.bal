import asus/json_rpc.'client;
import ballerina/io;
import asus/json_rpc.types;

public function main() {
    'client:WSClient wsClient = new("localhost",3000);
    wsClient.register();

    wsClient.sendRequest("add", {"x":100, "y": 80}, function (types:Response|types:Error u) returns () {
        io:println("1 : ", u);
    });

    wsClient.sendRequest("sub", {"x":100, "y": 80}, function (types:Response|types:Error u) returns () {
        io:println("2 : ", u);
    });
    
    wsClient.sendRequest("sub", 100, function (types:Response|types:Error u) returns () {
        io:println("3 : ", u);
    });


    wsClient.sendRequestBatch([{method: "add",params: {"x":100, "y": 80}}],function (types:BatchJRPCOutput|types:Error u) returns () {
        io:println("4 : ", u);
    });
    
    wsClient.sendRequestBatch([{method: "sub",params: {"x":100, "y": 80},notification: true},{method: "sub", params: {"x":100, "y": 80}}],function (types:BatchJRPCOutput|types:Error u) returns () {
        io:println("5 : ", u);
    });

    wsClient.sendRequestBatch([{method: "sub", params: {"x":100, "yz": 80}}],function (types:BatchJRPCOutput|types:Error u) returns () {
        io:println("6 : ", u);
    });
    
    wsClient.sendRequestBatch([{method: "sub",params: {"x":100, "y": 80},notification: true},{method: "sub", params: {"x":100, "y": 80}}],function (types:BatchJRPCOutput|types:Error u) returns () {
        io:println("7 : ", u);
    });

    wsClient.sendRequestBatch([{method: "add",params: {"x":100, "y": 80}},{method: "sub", params: {"x":100, "y": 80}}],function (types:BatchJRPCOutput|types:Error u) returns () {
        io:println("8 : ", u);
    });
    
    wsClient.sendRequestBatch([{method: "sub",params: {"x":100, "y": 80},notification: true},{method: "sub", params: {"x":100, "y": 80}}],function (types:BatchJRPCOutput|types:Error u) returns () {
        io:println("9 : ", u);
    });
    
    // wsClient.sendRequestBatch([],function (types:BatchJRPCOutput|types:Error u) returns () {
    //     io:println("6 : ", u);
    // });


    wsClient.closeClient();   
    
}
