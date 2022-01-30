import ballerina/websocket;
import ballerina/io;
import ballerina/lang.runtime;

string msg_1 = "Madusanka";
string msg_2 = "Nipunajith";
string msg_3 = "Dilshan";

public function main() {
    WSClient wsClient = new ("ws://localhost:3000");
    wsClient.register();

    User user = new (wsClient);

    user.func_1(msg_1, function(string s) returns () {
        io:println("Madusanka : ", s);
    });

    user.func_2(msg_2, function(string s) returns () {
        io:println("Nipunajith : ", s);
    });

    user.func_1(msg_3, function(string s) returns () {
        io:println("Dilshan : ", s);
    });

}


// method wrapper
public class User {
    private WSClient websocketClient;

    public function init(WSClient wsc) {
        self.websocketClient = wsc;
    }

    public function func_1(string request, function (string rep) reply) {
        self.websocketClient.sendMessage(request, function(string s) returns () {
            reply(s);
        });
    }

    public function func_2(string request, function (string rep) reply) {
        self.websocketClient.sendMessage(request, function(string s) returns () {
            reply(s);
        });
    }

    public function func_3() {

    }
}








// library 

string[] name = [];

public class ClientService {
    public function sendMessage(string message, function (string s) callback) {
        return;
    }

    public function sendNotification(string message) {
        return;
    }

    public function closeClient() {
        return;
    }
}

public class WSClient {
    *ClientService;

    websocket:Client wsClient;

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

        //rec = id , res  

        worker B {
            future<string> futureResult = start self.find(message);
            string unionResult = checkpanic wait futureResult;
            callback("recieved : " + unionResult);
        }
    }

    public function sendNotification(string message) {
        string msg = message;
        byte[] msgByteArray = msg.toBytes();
        checkpanic self.wsClient->writeBinaryMessage(msgByteArray);
    }

    public function closeClient() {
        return;
    }

    private function find(string request) returns string {
        while true {
            runtime:sleep(0.01);
            lock {
                foreach string item in name {
                    if item === request {
                        return item;
                    }
                }
            }

        }
    }

}
