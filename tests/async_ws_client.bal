import ballerina/io;
import ballerina/lang.'string;
import ballerina/websocket;

public function main() returns error? {
   
        websocket:Client wsClient = checkpanic new ("ws://localhost:3000");
        
        future<()> futureResult = start sendMessage(wsClient, "madusanka", function(string s) returns () {
            io:println("to B : ",s);
        });
        

        future<()> futureResult2 = start sendMessage(wsClient, "nipunajith", function(string s) returns () {
            io:println("to A : ",s);
        });
    
        map<error?|error?> _ = wait {futureResult,futureResult2};
}

function sendMessage(websocket:Client cl, string message, function (string reply) callback) {

    string msg = message;
    byte[] msgByteArray = msg.toBytes();
    checkpanic cl->writeBinaryMessage(msgByteArray); 

    //waiting for the reply
    future<byte[]|websocket:Error> listResult = start cl->readBinaryMessage();
    byte[]|websocket:Error response = wait listResult;


    if !(response is websocket:Error) {
        string reply = checkpanic string:fromBytes(response);
        callback("received: " + reply);
    }

}

