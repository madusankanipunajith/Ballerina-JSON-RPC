import ballerina/io;
//import ballerina/lang.runtime;
import ballerina/tcp;
public function main() returns error? {
    tcp:Client socketClient = check new ("localhost", 3000);

    worker A {
        //runtime:sleep(1);
        io:println("A");
        sendMessage(socketClient, "madusanka", function (string s) returns () {
            io:println(s); 
        });
    }

    io:println("B");
    sendMessage(socketClient, "Nipunajith", function (string s) returns () {
       io:println(s); 
    });

    //return socketClient->close();
}


function sendMessage(tcp:Client cl, string message, function (string reply) callback) {
    string msg = message;
    byte[] msgByteArray = msg.toBytes();
    checkpanic cl->writeBytes(msgByteArray);

    // waiting for the reply
    future<byte[] & readonly|tcp:Error> listResult = @strand {thread: "any"} start cl->readBytes();
    byte[] & readonly|tcp:Error response = wait listResult;

    if !(response is tcp:Error) {
        string reply = checkpanic string:fromBytes(response);
        callback("received: "+reply);
    }
}