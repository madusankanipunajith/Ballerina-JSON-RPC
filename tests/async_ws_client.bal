import ballerina/io;
import ballerina/lang.'string;
import ballerina/websocket;

public function main() returns error? {
    websocket:Client wsClient = check new ("ws://localhost:3000");

    worker B {
        io:println("B");
        sendMessage(wsClient, "madusanka", function(string s) returns () {
            io:println(s);
        });
    }

    worker A {
        io:println("A");
        sendMessage(wsClient, "nipunajith", function(string s) returns () {
            io:println(s);
        });
    }
}

function sendMessage(websocket:Client cl, string message, function (string reply) callback) {

    string msg = message;
    byte[] msgByteArray = msg.toBytes();
    checkpanic cl->writeBinaryMessage(msgByteArray); 

    // waiting for the reply
    future<byte[]|websocket:Error> listResult = @strand {thread: "any"} start cl->readBinaryMessage();
    byte[]|websocket:Error response = wait listResult;

    if !(response is websocket:Error) {
        string reply = checkpanic string:fromBytes(response);
        callback("received: " + reply);
    }

}

