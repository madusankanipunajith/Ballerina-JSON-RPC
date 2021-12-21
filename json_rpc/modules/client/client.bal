import json_rpc.types;
import ballerina/tcp;
import ballerina/udp;
import ballerina/io;

public enum Protocols {
    TCP, UDP
}
type BatchJRPCInput types:Request|types:Notification?[];
type SingleJRPCInput types:Request|types:Notification;


public class ClientServices {
    public function sendMessage(SingleJRPCInput|BatchJRPCInput message) {
        return;
    }

    public function fetchMessage() returns types:Response|types:Error?{
        return;
    }

    public function closeClient() {
        return;
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

    

    public function sendMessage(SingleJRPCInput|BatchJRPCInput message) {
        string jsonMessage = message.toJsonString(); 
        byte[] msgByteArray = jsonMessage.toBytes();
        checkpanic self.tcpClient->writeBytes(msgByteArray);
    }

    public function fetchMessage() returns types:Response|types:Error? {
        readonly & byte[] receivedData = checkpanic self.tcpClient->readBytes();
        io:println("Received: ", string:fromBytes(receivedData));
        return; 
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

    public function fetchMessage() returns types:Response|types:Error? {
        readonly & udp:Datagram result = checkpanic self.udpClient->receiveDatagram();
        io:println("Received: ", string:fromBytes(result.data));    
        return;
    }

    public function sendMessage(SingleJRPCInput|BatchJRPCInput message) {

        string jsonMessage = message.toJsonString();

        udp:Datagram datagram = {
            remoteHost: self.udpHost,
            remotePort : self.udpPort,
            data : jsonMessage.toBytes()
        };

        checkpanic self.udpClient->sendDatagram(datagram);

    }
}

public class Client {

    public function setConfig(string remoteHost, int remotePort, Protocols protocol) returns TCPClient|UDPClient|error {
        
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
            
        }

        return error("protocol is not initialized yet");
    }
}