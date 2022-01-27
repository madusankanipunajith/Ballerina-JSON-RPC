import ballerina/io;
import ballerina/lang.runtime;
import ballerina/websocket;

public function main() {
    websocket:Client wsClient = checkpanic new ("ws://localhost:3000");

    string msg_1 = "Madusanka";
    string msg_2 = "Nipunajith";
    string msg_3 = "Dulaj";
    string msg_4 = "Malintha";

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

    func_1(wsClient,msg_1,function (string s) returns () {
       io:println(msg_1+" : "+s); 
    });

    func_1(wsClient,msg_2,function (string s) returns () {
       io:println(msg_2+" : "+s); 
    });

    func_1(wsClient,msg_3,function (string s) returns () {
       io:println(msg_3+" : "+s); 
    });

    func_1(wsClient,msg_4,function (string s) returns () {
       io:println(msg_4+" : "+s); 
    });

}



string[] name = [];

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

function func_1(websocket:Client ws,string request , function (string rep) reply) {
    sendMessage(ws,request, function (string s) returns () {
        reply(s);
    });
}