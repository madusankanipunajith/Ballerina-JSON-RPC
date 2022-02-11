import ballerina/lang.runtime;
import json_rpc.'types;

# Create a response message according to the json rpc 2.0 specification
#
# + requestId - Id of the request message  
# + answer - Final answer/output of the method execution
# + return - Return a json rpc response message
public isolated function responseObject(int requestId, any answer) returns 'types:Response {
    'types:Response res = {
        id: requestId,
        result: <anydata>answer,
        jsonrpc: "2.0"
    };

    return res;
}

# Create an error for parse error according to the json rpc 2.0 specification
# + return - Return a json rpc error message  
public isolated function parseError() returns 'types:Error {
    'types:Error err = {
            id: null,
            err: {"code": "-32700", "message": "Parse error"},
            jsonrpc: "2.0"
    };

    return err;
}

# Create an error for method is not found according to the json rpc 2.0 specification
#
# + requestId - Id of the request message
# + return - Return a json rpc error message  
public isolated function methodNotFoundError(int requestId) returns 'types:Error {
    'types:Error err = {
        id: requestId,
        err: {code: "-32601", message: "method is not found"},
        jsonrpc: "2.0"
    };

    return err;
}

# Create an error for method parameters are invalid according to the json rpc 2.0 specification
#
# + requestId - Id of the request message
# + return - Return a json rpc error message   
public isolated function invalidMethodParams(int requestId) returns 'types:Error {
    'types:Error err = {
        id: requestId,
        err: {code: "-32602", message: "Invalid method parameters"},
        jsonrpc: "2.0"
    };

    return err;
}

# Create an error for server error according to the json rpc 2.0 specification
# + return - Return a json rpc error message  
public isolated function serverError() returns 'types:Error {
    'types:Error err = {
        id: null,
        err: {"code": "-32000", "message": "Server error"},
        jsonrpc: "2.0"
    };

    return err;
}

# Create an error for invalid request message according to the json rpc 2.0 specification
# + return - Return a json rpc error message  
public isolated function invalidRequestError() returns 'types:Error {
    'types:Error err = {
        id: null,
        err: {"code": "-32600", "message": "Invalid request"},
        jsonrpc: "2.0"
    };

    return err;
}

# Create a notification message according to the json rpc 2.0 specification
#
# + method - method name of the request 
# + params - Parameters of the request message (json or array)
# + return - Return a json rpc notification message
public isolated function sendNotification(string method, anydata params) returns 'types:Notification {
    'types:Notification notification = {
        method: method,
        params: params,
        jsonrpc: "2.0"
    };

    return notification;
}

# Create a request message according to the json rpc 2.0 specification
#
# + id - Id of the request message
# + method - method name of the request 
# + params - Parameters of the request message (json or array)
# + return - Return a json rpc request message
public isolated function sendRequest(int id, string method, anydata params) returns 'types:Request {
    'types:Request request = {
        id: id,
        method: method,
        params: params,
        jsonrpc: "2.0"
    };

    return request;
}

# Create a custom error message according to the json rpc 2.0 specification
#
# + id - Id of the request message  
# + err - error discription 
# + return - Return a json rpc error message
public isolated function sendError(int? id, json err) returns 'types:Error {
    'types:Error e = {
        id: id,
        err: err,
        jsonrpc: "2.0"
    };

    return e;
}

# Create a response message according to the json rpc 2.0 specification
#
# + id - Id of the request message  
# + result - Final result/output of the method execution
# + return - Return a json rpc response message
public isolated function sendResponse(int id, any result) returns 'types:Response {
    'types:Response response = {
        id: id,
        result: <anydata>result,
        jsonrpc: "2.0"
    };

    return response;
}


# This function is used to interleave the infinite loops which are concurrently running on different threads.
public isolated function nap() {
    runtime:sleep(0.1);
}