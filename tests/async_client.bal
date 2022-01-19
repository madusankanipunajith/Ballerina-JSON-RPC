import ballerina/io;
import ballerina/tcp;
public function main() returns error? {
    tcp:Client socketClient = check new ("localhost", 3000);

    worker A {
        io:println("A");
        sendMessage(socketClient, "madusanka", function (string s) returns () {
            io:println(s); 
        });
    }

    io:println("B");
    sendMessage(socketClient, "Nipunajith", function (string s) returns () {
       io:println(s); 
    });

    return socketClient->close();
}


function sendMessage(tcp:Client cl, string message, function (string reply) callback) {
    string msg = message;
    byte[] msgByteArray = msg.toBytes();
    checkpanic cl->writeBytes(msgByteArray);

    readonly & byte[] receivedData = checkpanic cl->readBytes();
    string response = checkpanic string:fromBytes(receivedData);
    callback("received: "+response);
}