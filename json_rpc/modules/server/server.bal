import json_rpc.'types;
import ballerina/websocket;
import ballerina/tcp;
import ballerina/udp;
import ballerina/log;
import json_rpc.util;

# Json rpc service array
public type JRPCSA JRPCService[];

# Abstract class for the service methods
public class JRPCMethods {

    # Inbuilt function for mapping the methods
    # + return - Returns the Methods mapper 
    public isolated function getMethods() returns types:Methods {
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
    private JRPCSA jrpcsa = []; // define an array of services
    private JRPCService jrpcservice = new (); // define a single service
    private boolean single; // identifier to find weather it is a single service or not(array of services)

    # Constructor
    #
    # + services - User initialized service/services
    public isolated function init(JRPCSA|JRPCService services) {
        if services is JRPCSA {
            self.jrpcsa = services;
            self.single = false;
        } else {
            self.jrpcservice = services;
            self.single = true;
        }

    }

    # Send the response message to the client
    #
    # + caller - Protocol identifer  
    # + request - Rrequest message as a byte array (marshalled data)
    public function sendResponse(util:Jcaller caller, byte[] request) {     
        string message = checkpanic string:fromBytes(request);
        byte[] response = self.run(message).toString().toBytes();
        if caller is websocket:Caller {
            checkpanic caller->writeBinaryMessage(response);
        } else if caller is udp:Caller {
            checkpanic caller->sendBytes(response);
        } else if caller is tcp:Caller {
            checkpanic caller->writeBytes(response);
        } else {
            log:printError(NOTSUPPORTEDPROTOCOL);
        }
        
    }

    # Executes the request message and returns the response message
    #
    # + message - String type message which is recieved from the client
    # + return - Return jrpc response/batch/error/nil
    private function run(string message) returns 'types:SingleJRPCOutput|'types:BatchJRPCOutput|() {
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
    private isolated function filterMethod('types:Request|'types:Notification result) returns 'types:Method|error {
        string method = result.method;
        'types:Methods allMethods = {};
        string serviceName = "";
        string methodName = "";

        if self.single {
            allMethods = self.jrpcservice.methods.getMethods();
            methodName = method;
        } else {
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
    private function executeSingleJsonRequest('types:Request message) returns 'types:Error|'types:Response|() {
        'types:Method|error mf = self.filterMethod(message);
        if mf is error {
            return util:methodNotFoundError(message.id);
        }

        types:Response|error|() executeResult = execute(message, mf);
        if executeResult is error {
            return util:internalError(message.id);
        } else {
            return executeResult;
        }

    }

    # Executes a single notification message
    #
    # + message - jrpc notification
    private function executeSingleJsonNotification('types:Notification message) returns () {
        'types:Method|error mf = self.filterMethod(message);

        // server never return an output even an error is triggered
        if mf is error {
            return ();
        }
        // server never return an output even the execution is triggered
        if execute(message, mf) is error|() {
            return ();
        }

    }

    # Executes a batch message
    #
    # + message - json array
    # + return - Return a batch response
    private function executeBatchJson(json[] message) returns 'types:BatchJRPCOutput {
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
