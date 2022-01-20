import ballerina/io;
import ballerina/websocket;
service / on new websocket:Listener(3000) {
   resource isolated function get .() returns websocket:Service|websocket:Error {
       return new WsService();
   }
}

service class WsService {
    *websocket:Service;
    remote isolated function onBinaryMessage(websocket:Caller caller, byte[] text) returns websocket:Error? {
        io:println("\ntext message: " , string:fromBytes(text));
        
        websocket:Error? writeBinaryMessage = caller->writeBinaryMessage(text);
        if !(writeBinaryMessage is websocket:Error){
            io:println("message sent");
        }
    }
}