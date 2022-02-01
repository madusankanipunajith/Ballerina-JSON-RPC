import json_rpc.types;
import ballerina/lang.value;
import json_rpc.validator;
import ballerina/lang.runtime;
import ballerina/time;
import ballerina/log;
import ballerina/tcp;
import ballerina/websocket;

public type BatchInput record {|
    boolean notification = false;
    string method;
    anydata params;
|};

public type BatchJRPCOutput 'types:JsonRPCTypes?[];

public type SingleJRPCOutput types:Response|types:Error;

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

function createRequest(int id, string method, anydata params) returns types:Request {
    types:Request request = {
        id: id,
        method: method,
        params: params
    };

    return request;
}

function createNotification(string method, anydata params) returns types:Notification {
    types:Notification notification = {
        method: method,
        params: params
    };

    return notification;
}

function createBatchRequest(BatchInput[] batch, Store store) returns types:JsonRPCTypes[] {
    types:JsonRPCTypes[] request = [];

    foreach BatchInput item in batch {
        if item.notification {
            types:Notification notific = {
                    params: item.params,
                    method: item.method
                };
            request.push(notific);
        } else {
            int id = store.genarateId();
            types:Request req = {
                id: id,
                params: item.params,
                method: item.method
            };
            request.push(req);
        }
    }

    return request;
}

function createBatchNotification(BatchInput[] batch) returns types:JsonRPCTypes[] {
    types:JsonRPCTypes[] notification = [];
    foreach BatchInput item in batch {
        types:Notification notific = {
            method: item.method,
            params: item.params
        };
        notification.push(notific);
    }

    return notification;
}

class Store {
    int id = 0;
    SingleJRPCOutput[] responseRequestStore = [];
    BatchJRPCOutput[] responseBatchStore = [];

    public function genarateId() returns int {
        self.id = self.id + 1;
        return self.id;
    }

    public function getRequestStore() returns SingleJRPCOutput[] {
        return self.responseRequestStore;
    }

    public function getBatchStore() returns BatchJRPCOutput[] {
        return self.responseBatchStore;
    }

    public function pushResponse(SingleJRPCOutput response) {
        self.responseRequestStore.push(response);
    }

    public function pushBatch(BatchJRPCOutput response) {
        self.responseBatchStore.push(response);
    }
}

public class ClientService {
    public function sendRequest(string method, anydata params, function (types:Response|types:Error response) callback) {
        return;
    }

    public function sendNotification(string method, anydata params) {
        return;
    }

    public function sendRequestBatch(BatchInput[] message, function (types:BatchJRPCOutput|types:Error response) callback) {
        return;
    }

    public function sendNotificationBatch(BatchInput[] message) {
        return;
    }

    public function closeClient() {
        return;
    }
}

public class WSClient {
    *ClientService;

    private websocket:Client wsClient;
    private Store store;

    public function init(string url) {
        self.wsClient = checkpanic new (url);
        self.store = new ();
    }

    public function register() {
        worker A {
            while true {
                future<byte[]|websocket:Error> futureResult = start self.wsClient->readBinaryMessage();
                byte[]|websocket:Error response = wait futureResult;

                lock {
                    if !(response is websocket:Error) {
                        string reply = checkpanic string:fromBytes(response);
                        types:JRPCResponse fetchResponseResult = fetchResponse(reply);

                        if fetchResponseResult is types:Response || fetchResponseResult is types:Error {
                            self.store.pushResponse(fetchResponseResult);
                            if fetchResponseResult.id === () {
                                log:printError("Unmatchable error has been recieved by server", 'error = error(fetchResponseResult.toString()));
                            }
                        } else if fetchResponseResult is BatchJRPCOutput {
                            self.store.pushBatch(fetchResponseResult);
                        } else {
                            continue;
                        }
                    }
                }
            }
        }
    }

    public function closeClient() {
        worker C {
            while true {
                runtime:sleep(0.01);
            }
        }

    }

    public function sendNotification(string method, anydata params) {
        string jsonMessage = createNotification(method, params).toJsonString();
        byte[] msgByteArray = jsonMessage.toBytes();
        checkpanic self.wsClient->writeBinaryMessage(msgByteArray);
    }

    public function sendNotificationBatch(BatchInput[] message) {
        string jsonMessage = createBatchNotification(message).toJsonString();
        byte[] msgByteArray = jsonMessage.toBytes();
        checkpanic self.wsClient->writeBinaryMessage(msgByteArray);
    }

    public function sendRequest(string method, anydata params, function (types:Response|types:Error response) returns () callback) {
        int id = self.store.genarateId();
        string jsonMessage = createRequest(id, method, params).toJsonString();
        byte[] msgByteArray = jsonMessage.toBytes();
        checkpanic self.wsClient->writeBinaryMessage(msgByteArray);

        worker B {
            future<types:Error|types:Response> futureResult = start self.findRequest(id);
            types:Error|types:Response unionResult = checkpanic wait futureResult;
            callback(unionResult);
        }
    }

    public function sendRequestBatch(BatchInput[] message, function (types:BatchJRPCOutput|types:Error response) returns () callback) {
        types:JsonRPCTypes[] request = [];
        int[] ids = [];
        foreach BatchInput item in message {
            if item.notification {
                types:Notification notific = {
                    params: item.params,
                    method: item.method
                };
                request.push(notific);
            } else {
                int id = self.store.genarateId();
                types:Request req = {
                    id: id,
                    params: item.params,
                    method: item.method
                };
                ids.push(id);
                request.push(req);
            }
        }

        string jsonMessage = request.toJsonString();
        byte[] msgByteArray = jsonMessage.toBytes();
        checkpanic self.wsClient->writeBinaryMessage(msgByteArray);

        worker B {
            future<BatchJRPCOutput|types:Error> futureResult = start self.findBatch(ids);
            BatchJRPCOutput|types:Error unionResult = checkpanic wait futureResult;
            callback(unionResult);
        }
    }

    private function findRequest(int id) returns types:Error|types:Response {
        time:Utc currentUtc = time:utcNow();
        int strats = currentUtc[0];
        int end = strats + 20;
        while (strats < end) {
            strats = time:utcNow()[0];
            runtime:sleep(0.01);
            lock {
                SingleJRPCOutput[] requestStore = self.store.getRequestStore();
                foreach types:Response|types:Error item in requestStore {
                    if item.id === id {
                        return item;
                    }
                }
            }
        }

        record {int id; string err;} err = {
            id: id,
            err: "Time out"
        };
        log:printError("Response message hasn't been recieved", 'error = error(err.toString()));

        types:Error e = {
            id: id,
            err: {message: "Time out"},
            jsonrpc: "2.0"
        };
        return e;
    }

    private function findBatch(int[] id) returns BatchJRPCOutput|types:Error {
        time:Utc currentUtc = time:utcNow();
        int strats = currentUtc[0];
        int end = strats + 20;
        while (strats < end) {
            strats = time:utcNow()[0];
            runtime:sleep(0.01);
            lock {
                BatchJRPCOutput[] batchStore = self.store.getBatchStore();
                foreach BatchJRPCOutput item in batchStore {
                    foreach int i in id {
                        foreach types:JsonRPCTypes? j in item {
                            if j is types:Response || j is types:Error {
                                if j.id === i {
                                    return item;
                                }
                            }
                        }
                    }
                }
            }
        }

        record {int[] id; string err;} err = {
            id: id,
            err: "Time out"
        };
        log:printError("Response batch message hasn't been recieved. Sent ids are shown in the message", 'error = error(err.toString()));

        types:Error e = {
            id: 404,
            err: {message: "Time out"},
            jsonrpc: "2.0"
        };
        return e;
    }
}

public class TCPClient {
    *ClientService;

    private tcp:Client tcpClient;
    private Store store;

    public function init(string host, int port) {
        self.tcpClient = checkpanic new (host, port);
        self.store = new ();
    }

    public function closeClient() {
        checkpanic self.tcpClient->close();
    }

    public function sendNotification(string method, anydata params) {
        string jsonMessage = createNotification(method, params).toJsonString();
        byte[] msgByteArray = jsonMessage.toBytes();
        checkpanic self.tcpClient->writeBytes(msgByteArray);
    }

    public function sendNotificationBatch(BatchInput[] message) {
        string jsonMessage = createBatchNotification(message).toJsonString();
        byte[] msgByteArray = jsonMessage.toBytes();
        checkpanic self.tcpClient->writeBytes(msgByteArray);
    }

    public function sendRequest(string method, anydata params, function (types:Response|types:Error response) returns () callback) {
        int id = self.store.genarateId();
        string jsonMessage = createRequest(id, method, params).toJsonString();
        byte[] msgByteArray = jsonMessage.toBytes();
        checkpanic self.tcpClient->writeBytes(msgByteArray);

        // waiting for the reply
        future<byte[] & readonly|tcp:Error> futureResult = start self.tcpClient->readBytes();
        byte[] & readonly|tcp:Error response = wait futureResult;

        if !(response is tcp:Error) {
            string reply = checkpanic string:fromBytes(response);
            types:Response|types:Error fetchResponseResult = <types:Response|types:Error>fetchResponse(reply);
            callback(fetchResponseResult);
        }
    }

    public function sendRequestBatch(BatchInput[] message, function (types:BatchJRPCOutput|types:Error response) returns () callback) {
        string jsonMessage = createBatchRequest(message, self.store).toString();
        byte[] msgByteArray = jsonMessage.toBytes();
        checkpanic self.tcpClient->writeBytes(msgByteArray);

        // waiting for the reply
        future<byte[] & readonly|tcp:Error> futureResult = start self.tcpClient->readBytes();
        byte[] & readonly|tcp:Error response = wait futureResult;
        
        if !(response is tcp:Error) {
            string reply = checkpanic string:fromBytes(response);
            types:BatchJRPCOutput|types:Error fetchResponseResult = <types:BatchJRPCOutput|types:Error>fetchResponse(reply);
            callback(fetchResponseResult);
        }
    }
}
















// class UDPClient {
//     *ClientServices;

//     private udp:Client udpClient;
//     private string udpHost;
//     private int udpPort;

//     public function init(string host, int port) {
//         self.udpPort = port;
//         self.udpHost = host;
//         self.udpClient = checkpanic new ({localHost: host});
//     }

//     public function closeClient() {
//         checkpanic self.udpClient->close();
//     }

//     public function sendMessage(SingleJRPCInput|BatchJRPCInput message) returns types:Response|types:Error|BatchJRPCOutput|null {

//         string jsonMessage = message.toJsonString();

//         udp:Datagram datagram = {
//             remoteHost: self.udpHost,
//             remotePort: self.udpPort,
//             data: jsonMessage.toBytes()
//         };

//         checkpanic self.udpClient->sendDatagram(datagram);

//         // waiting for the reply
//         future<udp:Datagram & readonly|udp:Error> listResult = start self.udpClient->receiveDatagram();
//         udp:Datagram & readonly|udp:Error response = wait listResult;

//         if !(response is udp:Error) {
//             string reply = checkpanic string:fromBytes(response.data);
//             return fetchResponse(reply);
//         }
//     }

//     public function sendNotification(types:Notification notification) {
//         string jsonMessage = notification.toJsonString();

//         udp:Datagram datagram = {
//             remoteHost: self.udpHost,
//             remotePort: self.udpPort,
//             data: jsonMessage.toBytes()
//         };

//         checkpanic self.udpClient->sendDatagram(datagram);
//     }
// }

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

//     public function sendMessage(SingleJRPCInput|BatchJRPCInput message) returns  types:Response|types:Error|BatchJRPCOutput|null{
//         string jsonMessage = message.toString(); 
//         byte[] msgByteArray = jsonMessage.toBytes();
//         checkpanic self.wsClient->writeBinaryMessage(msgByteArray);

//         // waiting for the response
//         future<byte[]|websocket:Error> futureResult = start self.wsClient->readBinaryMessage();
//         byte[]|websocket:Error response = wait futureResult;

//         if !(response is websocket:Error){
//             string reply = checkpanic string:fromBytes(response);
//             return fetchResponse(reply);
//         }
//     }

//     public function sendNotification(types:Notification notification) {
//         string jsonMessage = notification.toJsonString(); 
//         byte[] msgByteArray = jsonMessage.toBytes();
//         checkpanic self.wsClient->writeBinaryMessage(msgByteArray);

//         byte[] _ = checkpanic self.wsClient->readBinaryMessage();
//     }
// }

// public class Client {

//     private ClientServices clientService = new ();
//     private JRPCClientMethods jclmethods;
//     private string remoteHost;
//     private int remotePort;
//     private string path;

//     public function init(types:TCPConfig|types:UDPConfig|types:WSConfig clientProtocolConfig, JRPCClientMethods jclm) {

//         if clientProtocolConfig is types:TCPConfig {
//             io:println("TCP");
//             self.remoteHost = clientProtocolConfig.tcpRemoteHost;
//             self.remotePort = clientProtocolConfig.tcpRemotePort;
//             TCPClient tcpClient = new (self.remoteHost, self.remotePort);
//             self.clientService = tcpClient;
//         }
//         else if clientProtocolConfig is types:UDPConfig {
//             io:println("UDP");
//             self.remoteHost = clientProtocolConfig.udpRemoteHost;
//             self.remotePort = clientProtocolConfig.udpRemotePort;
//             UDPClient udpClient = new (self.remoteHost, self.remotePort);
//             self.clientService = udpClient;
//         }
//         else {
//             io:println("WS");
//             self.remoteHost = clientProtocolConfig.wsRemoteHost;
//             self.remotePort = clientProtocolConfig.wsRemotePort;
//             self.path = clientProtocolConfig.path;
//             WSClient wsClient = new(self.remoteHost, self.remotePort, self.path);
//             self.clientService = wsClient;
//         }

//         jclm.clientService = self.clientService;
//         self.jclmethods = jclm;
//     }

//     public function ops() returns JRPCClientMethods {
//         return self.jclmethods;
//     }

//     public function getClientService() returns ClientServices {
//         return self.clientService;
//     }

//     public function closeClient() {
//         self.clientService.closeClient();
//     }
// }

