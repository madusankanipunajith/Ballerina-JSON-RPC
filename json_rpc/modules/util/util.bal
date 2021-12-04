import json_rpc.'type;

public isolated function responseObject(int requestId, any answer) returns 'type:Response{
    'type:Response res={
        id: requestId,
        result: answer,
        jsonrpc: "2.0"
    };

    return res;
}


# Caller module Error
# + return - Return Value Description  
public isolated function parseError() returns 'type:Error{
    
    'type:Error err ={
            id: null,
            err: {"code": "-32700", "message": "Parse error"},
            jsonrpc: "2.0" 
    };

    return err;
}

# Caller module Error
#
# + requestId - Parameter Description
# + return - Return Value Description  
public isolated function methodNotFoundError(int requestId) returns 'type:Error{
    'type:Error err ={
        id: requestId,
        err: {code: "-32601", message: "method is not found"},
        jsonrpc: "2.0"
    };

    return err;
}

# Caller module Error
#
# + requestId - Parameter Description
# + return - Return Value Description  
public isolated  function invalidMethodParams(int requestId) returns 'type:Error{
    'type:Error err={
        id: requestId,
        err: {code: "-32602", message: "Invalid method parameters"},
        jsonrpc: "2.0"
    };

    return err;
}

# Caller module error 
# + return - Return Value Description  
public isolated  function serverError() returns 'type:Error{
 
    'type:Error err = {
        id: null,
        err: {"code": "-32000", "message": "Server error"},
        jsonrpc: "2.0"
    };

    return err;
}

# Caller module error
# + return - Return Value Description  
public isolated  function invalidRequestError() returns 'type:Error{
    'type:Error err = {
        id: null,
        err: {"code": "-32600", "message": "Invalid request"},
        jsonrpc: "2.0"
    };

    return err;
}


public isolated function sendNotification(string method, anydata params) returns 'type:Notification{

    'type:Notification notification={
        method:method,
        params:params,
        jsonrpc: "2.0"
    };
    
    return notification;
}

public isolated function sendRequest(int id, string method, anydata params) returns 'type:Request{
    
    'type:Request request ={
        id:id,
        method:method,
        params:params,
        jsonrpc: "2.0"
    };

    return request;
}

public isolated function sendError(int? id, json err) returns 'type:Error{
    'type:Error e ={
        id:id,
        err:err,
        jsonrpc:"2.0"
    };

    return e;
}

public isolated function sendResponse(int id, any result) returns 'type:Response{
    'type:Response response ={
        id:id,
        result:result,
        jsonrpc: "2.0"
    };

    return response;
}