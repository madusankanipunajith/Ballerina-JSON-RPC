import json_rpc.'types;
import json_rpc.util;

# User Input parameters in the server side functions  
public type Input 'types:InputFunc|anydata[];

# Json rpc service array
public type JRPCSA JRPCService[];

# Abstract class for the service methods
public class JRPCMethods {

    # Inbuilt function for mapping the methods
    # + return - Returns the Methods mapper 
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
    public isolated function name() returns string {
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
    public isolated function runner(string message) returns 'types:SingleJRPCOutput|'types:BatchJRPCOutput|() {
        'types:RequestType requestType = util:fetchRequest(message);

        if requestType is 'types:Error {
            return requestType;
        }

        if requestType is map<json> {
            if util:checkInput(requestType) is 'types:Request {
                return self.executeSingleJsonRequest(<'types:Request>util:checkInput(requestType));
            }

            if util:checkInput(requestType) is 'types:Error {
                return <'types:Error>util:checkInput(requestType);
            }

            if util:checkInput(requestType) is 'types:Notification {
                return self.executeSingleJsonNotification(<'types:Notification>util:checkInput(requestType));
            }

            if util:checkInput(requestType) is null {
                return ();
            }
        }

        if requestType is json[] {
            return self.executeBatchJson(requestType);
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
        return checkpanic execute(message, mf);
    }

    # Executes a single notification message
    #
    # + message - jrpc notification
    private isolated function executeSingleJsonNotification('types:Notification message) returns () {
        'types:Method|error mf = self.methodFilter(message);
        if mf is error {
            return ();
        }

        types:Response|null _ = checkpanic execute(message, mf);
        return ();
    }

    # Executes a batch message
    #
    # + message - json array
    # + return - Return a batch response
    private isolated function executeBatchJson(json[] message) returns 'types:BatchJRPCOutput {
        'types:BatchJRPCOutput batch_res_array = [];

        foreach var item in message {
            lock {
                if util:checkInput(item) is 'types:Request {
                    batch_res_array.push(self.executeSingleJsonRequest(<'types:Request>util:checkInput(item)));
                }
            }

            lock {
                if util:checkInput(item) is 'types:Notification {
                    // discarding the output of the executor
                    null _ = self.executeSingleJsonNotification(<'types:Notification>util:checkInput(item));
                }
            }

            lock {
                if util:checkInput(item) is 'types:Error {
                    batch_res_array.push(util:checkInput(item));
                }
            }
        }
        return batch_res_array;
    }

}
