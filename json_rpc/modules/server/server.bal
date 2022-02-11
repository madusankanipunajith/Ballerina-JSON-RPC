import json_rpc.caller;
import json_rpc.'types;
import json_rpc.util;

const METHODNOTFOUND = "method is not initialized or not found";

type BatchResponse 'types:JsonRPCTypes?[];

# User Input parameters in the server side functions  
public type Input 'types:InputFunc|anydata[];

# Json rpc service array
public type JRPCSA JRPCService[];

# Abstract class for the service methods
public class JRPCMethods {

    # Description
    # + return - Return Value Description
    public isolated function getMethods() returns types:Methods{
        return {};
    }
}

# Abstract class for the service class
#
# + methods - User should initialize an instance of service methods inside this class 
public class JRPCService {
    public JRPCMethods methods;

    # Constructor
    public isolated function init() {
        self.methods = new ();
    }

    
    # Auto genarated function to add service name 
    # + return - Return the service name which is defined by user
    public isolated function name() returns string|error {
        return "";
    }
}

# Server class
public class Server {
    private JRPCSA jrpcsa = [];

    # Constructor
    #
    # + services - User initialized service/services
    public isolated function init(JRPCSA services) {
        self.jrpcsa = services;
    }

    # Executes the request message and returns the response message
    #
    # + message - String type message which is recieved from the client
    # + return - Return jrpc response/batch/error/nil
    public isolated function runner(string message) returns 'types:JsonRPCTypes|BatchResponse|null {
        'types:Identy identity = caller:requestIdentifier(message);

        if identity is 'types:Error {
            return identity;
        }

        if identity is map<json> {
            if caller:checker(identity) is 'types:Request {
                return self.executeSingleJsonRequest(<'types:Request>caller:checker(identity));
            }

            if caller:checker(identity) is 'types:Error {
                return <'types:Error>caller:checker(identity);
            }

            if caller:checker(identity) is 'types:Notification {
                return self.executeSingleJsonNotification(<'types:Notification>caller:checker(identity));
            }

            if caller:checker(identity) is null {
                return null;
            }
        }

        if identity is json[] {
            return self.executeBatchJson(identity);
        }

        return util:serverError();
    }

    # Filter the specified method according to the request/notification message
    #
    # + result - jrpc request or response
    # + return - Return a method or error
    private isolated function methodFilter('types:Request|'types:Notification result) returns 'types:Method|error {
        string method = result.method;
        'types:Methods allMethods = {};
        string serviceName = "";
        string methodName = "";

        if self.jrpcsa.length() == 1 {
            allMethods = self.jrpcsa[0].methods.getMethods();
            methodName = method;
        } else if self.jrpcsa.length() > 1 {
            int? index = method.indexOf("/");
            if index is int {
                serviceName = string:substring(method, 0, index);
                methodName = string:substring(method, index + 1, method.length());
            } else {
                return error(METHODNOTFOUND);
            }

            foreach var item in self.jrpcsa {
                if item.name() == serviceName {
                    allMethods = item.methods.getMethods();
                    continue;
                }
            }
        } else {
            return error(METHODNOTFOUND);
        }

        'types:Method|error selectedMethod = trap allMethods.get(methodName);

        if selectedMethod is error {
            return error(METHODNOTFOUND);
        } else {
            return selectedMethod;
        }
    }

    # Executes a single request message
    #
    # + message - jrpc request
    # + return - Return jrpc response/error
    private isolated function executeSingleJsonRequest('types:Request message) returns 'types:Error|'types:Response|null {
        'types:Method|error mf = self.methodFilter(message);
        if mf is error {
            return util:methodNotFoundError(message.id);
        }
        return checkpanic caller:executor(message, mf);
    }

    # Executes a single notification message
    #
    # + message - jrpc notification
    # + return - Return nil
    private isolated function executeSingleJsonNotification('types:Notification message) returns null {
        'types:Method|error mf = self.methodFilter(message);
        if mf is error {
            return null;
        }

        types:Response|null _ = checkpanic caller:executor(message, mf);
        return null;
    }

    # Executes a batch message
    #
    # + message - json array
    # + return - Return a batch response
    private isolated function executeBatchJson(json[] message) returns BatchResponse {
        BatchResponse batch_res_array = [];

        foreach var item in message {
            lock {
                if caller:checker(item) is 'types:Request {
                    batch_res_array.push(self.executeSingleJsonRequest(<'types:Request>caller:checker(item)));
                }
            }

            lock {
                if caller:checker(item) is 'types:Notification {
                    // discarding the output of the executor
                    null _ = self.executeSingleJsonNotification(<'types:Notification>caller:checker(item));
                }
            }

            lock {
                if caller:checker(item) is 'types:Error {
                    batch_res_array.push(caller:checker(item));
                }
            }
        }
        return batch_res_array;
    }

}
