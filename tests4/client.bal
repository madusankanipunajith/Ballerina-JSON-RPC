import ballerina/websocket;
import ballerina/io;
import ballerina/lang.runtime;

string msg_1 = "Madusanka";
string msg_2 = "Nipunajith";
string msg_3 = "Dilshan";

public function main() {
    WSClient wsClient = new ("ws://localhost:3000");
    wsClient.register();

    wsClient.sendMessage(msg_1, function(string s) returns () {
        io:println("Madusanka : ", s);
    });

    wsClient.sendMessage(msg_2, function(string s) returns () {
        io:println("Nipunajith : ", s);
    });

    wsClient.sendMessage(msg_3, function(string s) returns () {
        io:println("Dilshan : ", s);
    });

}


// library 

string[] name = [];

public class ClientService {
    public function sendMessage(string message, function (string s) callback) {
        return;
    }

    public function closeClient() {
        return;
    }
}

public class WSClient {
    *ClientService;

    private websocket:Client wsClient;

    public function init(string url) {
        self.wsClient = checkpanic new (url);
    }

    public function register() {
        worker A {
            while true {
                //waiting for the reply
                future<byte[]|websocket:Error> listResult = start self.wsClient->readBinaryMessage();
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
    }

    public function sendMessage(string message, function (string s) callback) {
        string msg = message;
        byte[] msgByteArray = msg.toBytes();
        checkpanic self.wsClient->writeBinaryMessage(msgByteArray);

        worker B {
            future<string> futureResult = start self.find(name, message);
            string unionResult = checkpanic wait futureResult;
            callback("recieved : " + unionResult);
        }
    }

    public function closeClient() {
        return;
    }

    private function find(string[] messages, string request) returns string {
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

}
