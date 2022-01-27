import ballerina/io;
import ballerina/lang.'string;
import ballerina/lang.runtime;
import ballerina/websocket;

string[] name = [];

public function main() returns error? {

    websocket:Client wsClient = checkpanic new ("ws://localhost:3000");
    string msg_1 = "Madusanka";
    string msg_2 = "Nipunajith";
    string msg_3 = "Dulaj";

    worker A {
        while true {
            //waiting for the reply
            future<byte[]|websocket:Error> listResult = start wsClient->readBinaryMessage();
            byte[]|websocket:Error response = wait listResult;

            lock {
                if !(response is websocket:Error) {
                    string reply = checkpanic string:fromBytes(response);
                    io:println(reply);
                    name.push(reply);
                }
            }
        }
    }

    sendMessage(wsClient, msg_1, function(string s) returns () {
        io:println("first function");
        io:println("Madusanka : ", s);
    });

    sendMessage(wsClient, msg_2, function(string s) returns () {
        io:println("second function");
        io:println("Nipunajith : ", s);
    });

    sendMessage(wsClient, msg_3, function(string s) returns () {
        io:println("third function");
        io:println("Dulaj : ", s);
    });

}

function sendMessage(websocket:Client cl, string message, function (string reply) callback) {

    string msg = message;
    byte[] msgByteArray = msg.toBytes();
    checkpanic cl->writeBinaryMessage(msgByteArray);

    worker B {
        future<string> futureResult = start find(name, message);
        string unionResult = checkpanic wait futureResult;
        callback("recieved : " + unionResult);
    }

}

function find(string[] messages, string request) returns string {
    while true {
        runtime:sleep(0.01);
        lock {
            foreach string item in messages {
                if item === request {
                    return item;
                }
            }
        }

    }
}

// import ballerina/io;
// import ballerina/lang.runtime;
// public function main() {
//     sendMesssage("Madusanka", function (string s) returns () {
//        io:println(s); 
//     });

//     sendMesssage("Nipunajith", function (string s) returns () {
//        io:println(s); 
//     });
// }

// function sendMesssage(string name, function (string s) callback) {
//     worker A {
//         if name === "Madusanka"{
//             runtime:sleep(2);
//             callback("Hello "+name);
//         }else {
//             callback("Hello "+ name);
//         }
//     }
// }