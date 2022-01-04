import json_rpc.'types;

public isolated function responseObject(int requestId, any answer) returns 'types:Response{
    'types:Response res={
        id: requestId,
        result: <anydata> answer,
        jsonrpc: "2.0"
    };

    return res;
}


# Caller module Error
# + return - Return Value Description  
public isolated function parseError() returns 'types:Error{
    
    'types:Error err ={
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
public isolated function methodNotFoundError(int requestId) returns 'types:Error{
    'types:Error err ={
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
public isolated  function invalidMethodParams(int requestId) returns 'types:Error{
    'types:Error err={
        id: requestId,
        err: {code: "-32602", message: "Invalid method parameters"},
        jsonrpc: "2.0"
    };

    return err;
}

# Caller module error 
# + return - Return Value Description  
public isolated  function serverError() returns 'types:Error{
 
    'types:Error err = {
        id: null,
        err: {"code": "-32000", "message": "Server error"},
        jsonrpc: "2.0"
    };

    return err;
}

# Caller module error
# + return - Return Value Description  
public isolated  function invalidRequestError() returns 'types:Error{
    'types:Error err = {
        id: null,
        err: {"code": "-32600", "message": "Invalid request"},
        jsonrpc: "2.0"
    };

    return err;
}


public isolated function sendNotification(string method, anydata params) returns 'types:Notification{

    'types:Notification notification={
        method:method,
        params:params,
        jsonrpc: "2.0"
    };
    
    return notification;
}

public isolated function sendRequest(int id, string method, anydata params) returns 'types:Request{
    
    'types:Request request ={
        id:id,
        method:method,
        params:params,
        jsonrpc: "2.0"
    };

    return request;
}

public isolated function sendError(int? id, json err) returns 'types:Error{
    'types:Error e ={
        id:id,
        err:err,
        jsonrpc:"2.0"
    };

    return e;
}

public isolated function sendResponse(int id, any result) returns 'types:Response{
    'types:Response response ={
        id:id,
        result:<anydata> result,
        jsonrpc: "2.0"
    };

    return response;
}