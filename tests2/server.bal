import ballerina/io;
import ballerina/lang.runtime;
import ballerina/websocket;

service / on new websocket:Listener(3000) {
    resource isolated function get .() returns websocket:Service|websocket:Error {
        return new WsService();
    }
}

service class WsService {
    *websocket:Service;
    remote function onBinaryMessage(websocket:Caller caller, byte[] text) returns websocket:Error? {
        io:println("\ntext message: ", string:fromBytes(text));
        
        worker A {
            string|error message = string:fromBytes(text);
            if message is string && message === "Madusanka" {
                runtime:sleep(5);
            }

            websocket:Error? writeBinaryMessage = caller->writeBinaryMessage(text);
            if !(writeBinaryMessage is websocket:Error) {
                io:println("message sent");
            }
        }
    }
}

