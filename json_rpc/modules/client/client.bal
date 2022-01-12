import json_rpc.types;
import ballerina/tcp;
import ballerina/udp;
import ballerina/io;
import ballerina/lang.value;
import json_rpc.validator;
import ballerina/websocket;

type BatchJRPCInput types:Request|types:Notification?[];

type SingleJRPCInput types:Request;

type BatchJRPCOutput 'types:JsonRPCTypes?[];

function fetchResponse(string response) returns types:JRPCResponse {
    BatchJRPCOutput bjo = [];

    any|error fetchMessage = trap value:fromJsonString(response);

    if fetchMessage is any[] {
        if fetchMessage.length() === 0 {
            return <BatchJRPCOutput>[];
        } else {
            foreach var item in fetchMessage {
                bjo.push(validator:messageValidator(<json>item));
            }
            return bjo;
        }
    } else if fetchMessage is json {
        types:JsonRPCTypes result = validator:messageValidator(fetchMessage);
        types:Response|types:Error convirtedResponse = <types:Response|types:Error>result;
        return convirtedResponse;
    } else {
        return null;
    }
}

public class ClientServices {
    public function sendMessage(SingleJRPCInput|BatchJRPCInput message) returns types:JRPCResponse {
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
    public ClientServices clientService;

    public function init() {
        self.clientService = new ();
    }
}

class TCPClient {
    *ClientServices;

    private tcp:Client tcpClient;

    public function init(string host, int port) {
        self.tcpClient = checkpanic new (host, port);
    }

    public function closeClient() {
        checkpanic self.tcpClient->close();
    }

    public function sendMessage(SingleJRPCInput|BatchJRPCInput message) returns types:Response|types:Error|BatchJRPCOutput|null {
        string jsonMessage = message.toJsonString();
        byte[] msgByteArray = jsonMessage.toBytes();
        checkpanic self.tcpClient->writeBytes(msgByteArray);

        // waiting for the reply
        future<byte[] & readonly|tcp:Error> listResult = start self.tcpClient->readBytes();
        byte[] & readonly|tcp:Error response = wait listResult;

        if !(response is tcp:Error) {
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
        self.udpClient = checkpanic new ({localHost: host});
    }

    public function closeClient() {
        checkpanic self.udpClient->close();
    }

    public function sendMessage(SingleJRPCInput|BatchJRPCInput message) returns types:Response|types:Error|BatchJRPCOutput|null {

        string jsonMessage = message.toJsonString();

        udp:Datagram datagram = {
            remoteHost: self.udpHost,
            remotePort: self.udpPort,
            data: jsonMessage.toBytes()
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
            remotePort: self.udpPort,
            data: jsonMessage.toBytes()
        };

        checkpanic self.udpClient->sendDatagram(datagram);
    }
}

class WSClient {
    *ClientServices;

    private websocket:Client wsClient;
    private string wsHost;
    private string wsPort;
    private string subProtocol;

    public function init(string host, int port, string subProtocol="") {
        self.wsHost = host;
        self.wsPort = <string> port.toString();
        self.subProtocol = subProtocol;

        string url = "ws://"+self.wsHost+":"+self.wsPort; io:println(url);

        if subProtocol.trim().length() > 0 {
            url = url+subProtocol;    
        }

        self.wsClient = checkpanic new(url);

    }

    public function closeClient() {
        return;
    }

    public function sendMessage(SingleJRPCInput|BatchJRPCInput message) returns  types:Response|types:Error|BatchJRPCOutput|null{
        string jsonMessage = message.toString(); 
        byte[] msgByteArray = jsonMessage.toBytes();
        checkpanic self.wsClient->writeBinaryMessage(msgByteArray);

        // waiting for the response
        future<byte[]|websocket:Error> futureResult = start self.wsClient->readBinaryMessage();
        byte[]|websocket:Error response = wait futureResult;

        if !(response is websocket:Error){
            string reply = checkpanic string:fromBytes(response);
            return fetchResponse(reply);
        }
    }

    public function sendNotification(types:Notification notification) {
        string jsonMessage = notification.toJsonString(); 
        byte[] msgByteArray = jsonMessage.toBytes();
        checkpanic self.wsClient->writeBinaryMessage(msgByteArray);

        byte[] _ = checkpanic self.wsClient->readBinaryMessage();
    }
}

public class Client {

    private ClientServices clientService = new ();
    private JRPCClientMethods jclmethods;
    private string remoteHost;
    private int remotePort;
    private string path;

    public function init(types:TCPConfig|types:UDPConfig|types:WSConfig clientProtocolConfig, JRPCClientMethods jclm) {

        if clientProtocolConfig is types:TCPConfig {
            io:println("TCP");
            self.remoteHost = clientProtocolConfig.tcpRemoteHost;
            self.remotePort = clientProtocolConfig.tcpRemotePort;
            TCPClient tcpClient = new (self.remoteHost, self.remotePort);
            self.clientService = tcpClient;
        }
        else if clientProtocolConfig is types:UDPConfig {
            io:println("UDP");
            self.remoteHost = clientProtocolConfig.udpRemoteHost;
            self.remotePort = clientProtocolConfig.udpRemotePort;
            UDPClient udpClient = new (self.remoteHost, self.remotePort);
            self.clientService = udpClient;
        }
        else {
            io:println("WS");
            self.remoteHost = clientProtocolConfig.wsRemoteHost;
            self.remotePort = clientProtocolConfig.wsRemotePort;
            self.path = clientProtocolConfig.path;
            WSClient wsClient = new(self.remoteHost, self.remotePort, self.path);
            self.clientService = wsClient;
        }

        jclm.clientService = self.clientService;
        self.jclmethods = jclm;
    }

    public function ops() returns JRPCClientMethods {
        return self.jclmethods;
    }

    public function getClientService() returns ClientServices {
        return self.clientService;
    }

    public function closeClient() {
        self.clientService.closeClient();
    }
}

