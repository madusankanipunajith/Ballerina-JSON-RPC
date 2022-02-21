import json_rpc.types;
import ballerina/time;
import ballerina/log;
import ballerina/tcp;
import json_rpc.util;
import ballerina/udp;
import ballerina/websocket;

# Private types and methods 
type BatchJRPCOutput 'types:JRPCTypes?[];

type SingleJRPCOutput types:Response|types:Error;

# This private class is used to manage central store
class Store {
    int id = 0;
    types:Request[] requestStore = [];
    SingleJRPCOutput[] responseStore = [];
    BatchJRPCOutput[] responseBatchStore = [];

    public function genarateId() returns int {
        self.id = self.id + 1;
        return self.id;
    }

    public function getResponseStore() returns types:SingleJRPCOutput[] {
        lock {
            return self.responseStore;
        }
    }

    public function getRequestStore() returns types:Request[] {
        lock {
            return self.requestStore;
        }
    }

    public function getBatchStore() returns BatchJRPCOutput[] {
        lock {
            return self.responseBatchStore;
        }
    }

    public function pushResponse(types:SingleJRPCOutput response) {
        lock {
            self.responseStore.push(response);
        }
    }

    public function pushBatch(BatchJRPCOutput response) {
        lock {
            self.responseBatchStore.push(response);
        }
    }

    public function pushRequest(types:Request request) {
        lock {
            self.requestStore.push(request);
        }
    }

    public function findResponse(int id) returns types:Error|types:Response {
        time:Utc currentUtc = time:utcNow();
        int strats = currentUtc[0];
        int end = strats + 10;
        while (strats < end) {
            strats = time:utcNow()[0];
            util:nap();
            lock {
                SingleJRPCOutput[] responseStore = self.getResponseStore();
                foreach types:Response|types:Error item in responseStore {
                    if item.id === id {
                        return item;
                    }
                }
            }
        }

        log:printError(NOT_RECIEVED, 'error = error(self.removeRequest(id).toString()));

        types:Error e = {
            id: id,
            err: {message: "Time out"},
            jsonrpc: "2.0"
        };
        return e;
    }

    public function findBatch(int[] id) returns BatchJRPCOutput|types:Error {
        time:Utc currentUtc = time:utcNow();
        int strats = currentUtc[0];
        int end = strats + 10;
        while (strats < end) {
            strats = time:utcNow()[0];
            util:nap();
            lock {
                BatchJRPCOutput[] batchStore = self.getBatchStore();
                foreach BatchJRPCOutput item in batchStore {
                    foreach int i in id {
                        foreach types:JRPCTypes? j in item {
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

        if id.length() > 0 {
            foreach int i in id {
                log:printError(NOT_RECIEVED, 'error = error(self.removeRequest(i).toString()));
            }
        } else {
            log:printError(NOT_RECIEVED, 'error = error(EMPTY_MESSAGE));
        }

        types:Error e = {
            id: 404,
            err: {message: "Time out"},
            jsonrpc: "2.0"
        };
        return e;
    }

    public function removeRequest(int|int[] id) returns types:Request|() {
        int index = 0;
        if id is int[] {
            foreach int item in id {
                lock {
                    foreach int i in 0 ..< self.requestStore.length() {
                        if self.requestStore[i].id === item {
                            index = i;
                            _ = self.requestStore.remove(index);
                        }
                    }
                }
            }
            return ();
        } else {
            lock {
                foreach int i in 0 ..< self.requestStore.length() {
                    if self.requestStore[i].id === id {
                        index = i;
                    }
                }

                return self.requestStore.remove(index);
            }
        }
    }

    public function removeResponse(int|int[] id) {
        int index = 0;
        if id is int[] {
            foreach int i in id {
                lock {
                    foreach int ind in 0 ..< self.responseBatchStore.length() {
                        BatchJRPCOutput batchJRPCOutput = self.responseBatchStore[ind];
                        foreach var item in batchJRPCOutput {
                            if item is types:Response || item is types:Error {
                                if item.id === i {
                                    index = ind;
                                    _ = self.responseBatchStore.remove(index);
                                    return;
                                }
                            }
                        }
                    }
                }
            }
        } else {
            lock {
                foreach int i in 0 ..< self.responseStore.length() {
                    if self.responseStore[i].id === id {
                        index = i;
                        break;
                    }
                }
                _ = self.responseStore.remove(index);
            }
        }
    }
}

# All the client services are defined here 
public class ClientService {

    # Client can send a Request message to the server
    #
    # + method - Define the method of the message   
    # + params - Define the parameters of the message   
    # + callback - Define a callback function which returns an output(response or error) for the particular sent Request. 
    public function sendRequest(string method, anydata params, function (types:Response|types:Error response) callback) {
        return;
    }

    # Client can send a Notification message to the server
    #
    # + method - Define the method of the message  
    # + params - Define the parameters of the message 
    public function sendNotification(string method, anydata params) {
        return;
    }

    # Client can send a batch(collection) of Request messages to the server
    #
    # + message - array of BatchInput data types(Request/Notification)  
    # + callback - This function returns a response(Batch/Error) for particular sent request batch. 
    public function sendRequestBatch(types:BatchInput[] message, function (types:BatchJRPCOutput|types:Error response) callback) {
        return;
    }

    # Client can send a batch(collection) of Notification messages to the server
    #
    # + message - array of BatchInput data types
    public function sendNotificationBatch(types:BatchInput[] message) {
        return;
    }

    # Client can close the defined client from the server
    public function closeClient() {
        return;
    }
}
# Create a client using WS protocol (working asynchronously)
public class WSClient {
    *ClientService;

    private websocket:Client wsClient;
    private Store store;

    # Constructor of the websocket client (WSClient class) 
    #
    # + host - Remote host (localhost) 
    # + port - Remote port (3000)
    public function init(string host, int port) {
        string url = "ws://" + host + ":" + port.toString();
        self.wsClient = checkpanic new (url);
        self.store = new ();
    }

    # The function is which is used to register the client
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
                                log:printError(UNMATCHED_ERROR, 'error = error(fetchResponseResult.toString()));
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

    # Emplimentation of the closeClient method
    public function closeClient() {
        log:printInfo("Total : " + self.store.requestStore.length().toJsonString());
        while true {
            util:nap();
            lock {
                if self.store.requestStore.length() === 0 {
                    websocket:Error? close = self.wsClient->close(1000, REASON, 5);
                    if !(close is websocket:Error) {
                        log:printInfo(DISCONNECT);
                        break;
                    } else {
                        log:printInfo(DISCONNECT_ERROR);
                    }

                    break;
                }
            }
        }

    }

    # Emplimentation of the sendNotification method
    #
    # + method - Define the method of the message   
    # + params - Define the parameters of the message  
    public function sendNotification(string method, anydata params) {
        string jsonMessage = util:sendNotification(method, params).toJsonString();
        byte[] msgByteArray = jsonMessage.toBytes();
        checkpanic self.wsClient->writeBinaryMessage(msgByteArray);
    }

    # Emplimentation of the sendNotificationBatch method
    #
    # + message - array of BatchInput data types
    public function sendNotificationBatch(types:BatchInput[] message) {
        string jsonMessage = createBatchNotification(message).toJsonString();
        byte[] msgByteArray = jsonMessage.toBytes();
        checkpanic self.wsClient->writeBinaryMessage(msgByteArray);
    }

    # Emplimentation of the sendRequest method in async way
    #
    # + method - Define the method of the message   
    # + params - Define the parameters of the message   
    # + callback - Define a callback function which returns the output for particular sent Request asynchronously.
    public function sendRequest(string method, anydata params, function (types:Response|types:Error response) returns () callback) {
        int id = self.store.genarateId();
        self.store.pushRequest(util:sendRequest(id, method, params));
        string jsonMessage = util:sendRequest(id, method, params).toJsonString();
        byte[] msgByteArray = jsonMessage.toBytes();
        checkpanic self.wsClient->writeBinaryMessage(msgByteArray);

        worker B {
            future<types:Error|types:Response> futureResult = start self.store.findResponse(id);
            types:Error|types:Response unionResult = checkpanic wait futureResult;
            self.store.removeResponse(id);
            callback(unionResult);
            _ = self.store.removeRequest(id);
        }
    }

    # Emplimentation of the sendRequestBatch method in async way
    #
    # + message - array of BatchInput data types  
    # + callback - This function returns the response for particular sent request batch asynchronously. 
    public function sendRequestBatch(types:BatchInput[] message, function (types:BatchJRPCOutput|types:Error response) returns () callback) {
        types:JRPCTypes[] request = [];
        int[] ids = [];
        foreach types:BatchInput item in message {
            if item.notification {
                request.push(util:sendNotification(item.method, item.params));
            } else {
                int id = self.store.genarateId();
                types:Request req = util:sendRequest(id, item.method, item.params);
                ids.push(id);
                request.push(req);
                self.store.pushRequest(req);
            }
        }

        string jsonMessage = request.toJsonString();
        byte[] msgByteArray = jsonMessage.toBytes();
        checkpanic self.wsClient->writeBinaryMessage(msgByteArray);

        worker B {
            future<BatchJRPCOutput|types:Error> futureResult = start self.store.findBatch(ids);
            BatchJRPCOutput|types:Error unionResult = checkpanic wait futureResult;
            self.store.removeResponse(ids);
            callback(unionResult);
            _ = self.store.removeRequest(ids);
        }
    }
}

# Create a client using TCP protocol (working synchronously)
public class TCPClient {
    *ClientService;

    private tcp:Client tcpClient;
    private Store store;

    public function init(string host, int port) {
        self.tcpClient = checkpanic new (host, port);
        self.store = new ();
    }

    public function closeClient() {
        tcp:Error? close = self.tcpClient->close();
        if !(close is tcp:Error) {
            log:printInfo(DISCONNECT);
        } else {
            log:printInfo(DISCONNECT_ERROR);
        }
    }

    public function sendNotification(string method, anydata params) {
        string jsonMessage = util:sendNotification(method, params).toJsonString();
        byte[] msgByteArray = jsonMessage.toBytes();
        checkpanic self.tcpClient->writeBytes(msgByteArray);
    }

    public function sendNotificationBatch(types:BatchInput[] message) {
        string jsonMessage = createBatchNotification(message).toJsonString();
        byte[] msgByteArray = jsonMessage.toBytes();
        checkpanic self.tcpClient->writeBytes(msgByteArray);
    }

    public function sendRequest(string method, anydata params, function (types:Response|types:Error response) returns () callback) {
        int id = self.store.genarateId();
        string jsonMessage = util:sendRequest(id, method, params).toJsonString();
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

    public function sendRequestBatch(types:BatchInput[] message, function (types:BatchJRPCOutput|types:Error response) returns () callback) {
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

public class UDPClient {
    *ClientService;

    private udp:ConnectClient udpClient;
    private Store store;

    public function init(string host, int port) {
        self.udpClient = checkpanic new (host, port);
        self.store = new ();
    }

    public function register() {
        worker A {
            while true {
                future<(byte[] & readonly)|udp:Error> futureResult = start self.udpClient->readBytes();
                (byte[] & readonly)|udp:Error response = wait futureResult;
                lock {
                    if !(response is udp:Error) {
                        string reply = checkpanic string:fromBytes(response);
                        types:JRPCResponse fetchResponseResult = fetchResponse(reply);

                        if fetchResponseResult is types:Response || fetchResponseResult is types:Error {
                            if fetchResponseResult.id === () {
                                log:printError(UNMATCHED_ERROR,'error = error(fetchResponseResult.toString()));
                            } else {
                                self.store.pushResponse(fetchResponseResult);
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
        log:printInfo("Total : " + self.store.requestStore.length().toJsonString());
        while true {
            util:nap();
            lock {
                if self.store.requestStore.length() === 0 {
                    udp:Error? close = self.udpClient->close();
                    if !(close is udp:Error) {
                        log:printInfo(DISCONNECT);
                        break;
                    } else {
                        log:printInfo(DISCONNECT_ERROR);
                    }

                    break;
                }
            }
        }
    }

    public function sendNotification(string method, anydata params) {
        string jsonMessage = util:sendNotification(method, params).toJsonString();
        byte[] msgByteArray = jsonMessage.toBytes();
        checkpanic self.udpClient->writeBytes(msgByteArray);
    }

    public function sendNotificationBatch(types:BatchInput[] message) {
        string jsonMessage = createBatchNotification(message).toJsonString();
        byte[] msgByteArray = jsonMessage.toBytes();
        checkpanic self.udpClient->writeBytes(msgByteArray);
    }

    public function sendRequest(string method, anydata params, function (types:Response|types:Error response) returns () callback) {
        int id = self.store.genarateId();
        self.store.pushRequest(util:sendRequest(id,method,params));
        string jsonMessage = util:sendRequest(id,method,params).toJsonString();
        byte[] msgByteArray = jsonMessage.toBytes();
        checkpanic self.udpClient->writeBytes(msgByteArray);

        worker B {
            future<types:Error|types:Response> futureResult = start self.store.findResponse(id);
            types:Error|types:Response unionResult = checkpanic wait futureResult;
            self.store.removeResponse(id);
            callback(unionResult);
            _ = self.store.removeRequest(id);
        }
    }

    public function sendRequestBatch(types:BatchInput[] message, function (types:BatchJRPCOutput|types:Error response) returns () callback) {
        types:JRPCTypes[] request = [];
        int[] ids = [];
        foreach types:BatchInput item in message {
            if item.notification {
                request.push(util:sendNotification(item.method, item.params));
            } else {
                int id = self.store.genarateId();
                types:Request req = util:sendRequest(id, item.method, item.params);
                ids.push(id);
                request.push(req);
                self.store.pushRequest(req);
            }
        }

        string jsonMessage = request.toJsonString();
        byte[] msgByteArray = jsonMessage.toBytes();
        checkpanic self.udpClient->writeBytes(msgByteArray);

        worker B {
            future<BatchJRPCOutput|types:Error> futureResult = start self.store.findBatch(ids);
            BatchJRPCOutput|types:Error unionResult = checkpanic wait futureResult;
            self.store.removeResponse(ids);
            callback(unionResult);
            _ = self.store.removeRequest(ids);
        }
    }
}


