import ballerina/io;
import ballerina/log;
import ballerina/tcp;


# defService is an isolated function which is used for managing concurrency.
# + return - Return conncetionService instance or an error  
public isolated  function defService() returns tcp:ConnectionService | tcp:Error{
    tcp:ConnectionService csv = new Service();
    return csv;
}

service class Service {
    *tcp:ConnectionService;
    remote function onBytes(tcp:Caller caller, readonly & byte[] data) returns tcp:Error? {
        io:println("Echo: ", string:fromBytes(data));
        return caller->writeBytes(data);
    }

    remote function onError(tcp:Error err) {
        log:printError("An error occurred", 'error = err);
    }

    remote function onClose() {
        io:println("Client left");
    }
}