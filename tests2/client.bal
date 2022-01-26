import ballerina/io;
import ballerina/lang.'string;
import ballerina/websocket;

int x = 10;
public function main() returns error? {

    websocket:Client wsClient = checkpanic new ("ws://localhost:3000");
    string msg_1 = "Madusanka";
    string msg_2 = "Nipunajith";
    string msg_3 = "Dulaj";
    //byte[] msgByteArray = msg_1.toBytes();
    //byte[] msgByteArray2 = msg_2.toBytes();

    sendMessage(wsClient, msg_1, function(string s) returns () {
        io:println(x);
        io:println("Madusanka : ", s);
    });

    sendMessage(wsClient, msg_2, function(string s) returns () {
        io:println("Nipunajith : ", s);
    });

    sendMessage(wsClient, msg_3, function(string s) returns () {
        io:println("Dulaj : ", s);
    });

    // worker A {

    //     while true {
    //         byte[] byteResp = checkpanic wsClient->readBinaryMessage();
    //         string stringResp = checkpanic 'string:fromBytes(byteResp);
    //         if stringResp === "Madusanka" {
    //             io:println("Madusanka : recieved");
    //         } else {
    //             io:println("Nipunajith : recieved");
    //         }
    //         //io:println(stringResp);
    //     }
    // }

    // checkpanic wsClient->writeBinaryMessage(msgByteArray);
    // checkpanic wsClient->writeBinaryMessage(msgByteArray2);

    // worker B {
    //     while true {
    //         byte[] byteResp = checkpanic wsClient->readBinaryMessage();
    //         string stringResp = checkpanic 'string:fromBytes(byteResp);
    //         if stringResp === "Madusanka"{
    //            io:println("Madusanka : recieved2"); 
    //         }else{
    //            io:println("Nipunajith : recieved2");
    //         }
    //         //io:println(stringResp);
    //     }
    // }

    //io:println("close client");
}

function sendMessage(websocket:Client cl, string message, function (string reply) callback) {

    string msg = message;
    byte[] msgByteArray = msg.toBytes();
    checkpanic cl->writeBinaryMessage(msgByteArray);

    worker A {
        x = 11;
        while true {
            //waiting for the reply
            future<byte[]|websocket:Error> listResult =  start cl->readBinaryMessage();
            byte[]|websocket:Error response = wait listResult;

            if !(response is websocket:Error){
                string reply = checkpanic string:fromBytes(response);
                
                if (message === reply){
                    callback("received: " + reply);
                }
               
            }
        }
    }

}
