import json_rpc.types;
import ballerina/tcp;
import ballerina/udp;
import ballerina/io;
import ballerina/lang.value;
import json_rpc.validator;
//import ballerina/websocket;

public enum Protocols {
    TCP, UDP, WS
}
type BatchJRPCInput types:Request|types:Notification?[];
type SingleJRPCInput types:Request;
type BatchJRPCOutput 'types:JsonRPCTypes?[]; 

function fetchResponse(string response) returns types:JRPCResponse{
    any|error fetchMessage = trap value:fromJsonString(response);

    if fetchMessage is any[]{
     
        return <BatchJRPCOutput>fetchMessage;
    
    }else if fetchMessage is json{

        types:JsonRPCTypes result = validator:messageValidator(fetchMessage);
        types:Response|types:Error convirtedResponse = <types:Response|types:Error> result;
        return convirtedResponse;
    
    }else{

        return null;
    
    }
}

public class ClientServices {
    public function  sendMessage(SingleJRPCInput|BatchJRPCInput message) returns types:JRPCResponse{
        return;
    }

    public function sendNotification(types:Notification notification) {
        return;
    }


    public function closeClient() {
        return;
    }
}

// method wrapper
public class JRPCClientMethods {
    public ClientServices clientServices;
    public function init(ClientServices cls) {
        self.clientServices = cls;
    }
}

class TCPClient {
    *ClientServices;

    private tcp:Client tcpClient;

    public function init(string host, int port) {
        self.tcpClient = checkpanic new(host, port);
    }

    public function closeClient() {
        checkpanic self.tcpClient->close();
    }

    

    public function sendMessage(SingleJRPCInput|BatchJRPCInput message) returns types:Response|types:Error|BatchJRPCOutput|null{
        string jsonMessage = message.toJsonString(); 
        byte[] msgByteArray = jsonMessage.toBytes();
        checkpanic self.tcpClient->writeBytes(msgByteArray);

        // waiting for the reply
        future<byte[] & readonly|tcp:Error> listResult = start self.tcpClient->readBytes();
        byte[] & readonly|tcp:Error response = wait listResult;

        if !(response is tcp:Error){
            string reply = checkpanic string:fromBytes(response);
            
            return fetchResponse(reply);
            
        }
    }

    public function sendNotification(types:Notification notification) {

        string jsonMessage = notification.toJsonString(); 
        byte[] msgByteArray = jsonMessage.toBytes();
        checkpanic self.tcpClient->writeBytes(msgByteArray);
    }

}

class UDPClient {
    *ClientServices;

    private udp:Client udpClient;
    private string udpHost;
    private int udpPort;

    public function init(string host, int port) {
        self.udpPort = port;
        self.udpHost = host;
        self.udpClient = checkpanic new({localHost: host});
    }
    public function closeClient() {
        checkpanic self.udpClient->close();
    }


    public function sendMessage(SingleJRPCInput|BatchJRPCInput message) returns types:Response|types:Error|BatchJRPCOutput|null{

        string jsonMessage = message.toJsonString();

        udp:Datagram datagram = {
            remoteHost: self.udpHost,
            remotePort : self.udpPort,
            data : jsonMessage.toBytes()
        };

        checkpanic self.udpClient->sendDatagram(datagram);

        // waiting for the reply
        future<udp:Datagram & readonly|udp:Error> listResult = start self.udpClient->receiveDatagram();
        udp:Datagram & readonly|udp:Error response = wait listResult;

        if !(response is udp:Error) {
            string reply = checkpanic string:fromBytes(response.data);
            return fetchResponse(reply);
        }

    }

    public function sendNotification(types:Notification notification) {
        string jsonMessage = notification.toJsonString();

        udp:Datagram datagram = {
            remoteHost: self.udpHost,
            remotePort : self.udpPort,
            data : jsonMessage.toBytes()
        };

        checkpanic self.udpClient->sendDatagram(datagram);
    }
}



// class WSClient {
//     *ClientServices;

//     private websocket:Client wsClient;
//     private string wsHost;
//     private string wsPort;
//     private string subProtocol;

//     public function init(string host, int port, string subProtocol="") {
//         self.wsHost = host;
//         self.wsPort = <string> port.toString();
//         self.subProtocol = subProtocol;

//         string url = "ws://"+self.wsHost+":"+self.wsPort; io:println(url);
        
//         if subProtocol.trim().length() > 0 {
//             url = url+subProtocol;    
//         }

//         self.wsClient = checkpanic new(url);
        
//     }

//     public function closeClient() {
//         return;
//     }

//     public function sendMessage(SingleJRPCInput|BatchJRPCInput message, function (types:Response|types:Error response) returns () callback) {
//         string jsonMessage = message.toString(); 
//         byte[] msgByteArray = jsonMessage.toBytes();
//         checkpanic self.wsClient->writeBinaryMessage(msgByteArray);

//         // waiting for the response
//         future<byte[]|websocket:Error> futureResult = start self.wsClient->readBinaryMessage();
//         byte[]|websocket:Error response = wait futureResult;

//         if !(response is websocket:Error){
//             string reply = checkpanic string:fromBytes(response);
//             json jsonReply = checkpanic value:fromJsonString(reply);

//             types:JsonRPCTypes result = validator:messageValidator(jsonReply);
//             types:Response|types:Error convirtedResponse = <types:Response|types:Error> result;
            
//             callback(convirtedResponse);
//         }
//     }

//     public function sendNotification(types:Notification notification) {
//         string jsonMessage = notification.toJsonString(); 
//         byte[] msgByteArray = jsonMessage.toBytes();
//         checkpanic self.wsClient->writeBinaryMessage(msgByteArray);

//         byte[] _ = checkpanic self.wsClient->readBinaryMessage();
//     }
// }

public class Client {

    public function setConfig(string remoteHost, int remotePort, Protocols protocol, string path="") returns TCPClient|UDPClient|error {
        
        match protocol {
            
            "TCP" => {
                TCPClient tcpClient = new(remoteHost, remotePort);
                io:println("TCP");
                return tcpClient;
            }

            "UDP" =>{
                UDPClient udpClient = new(remoteHost, remotePort);
                io:println("UDP");
                return udpClient;
            }

            // "WS" =>{
            //     WSClient wsClient = new(remoteHost, remotePort, path);
            //     io:println("WS");
            //     return wsClient;
            // }
            
        }

        return error("protocol is not initialized yet");
    }
}

