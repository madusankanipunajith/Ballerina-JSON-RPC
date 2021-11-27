import json_rpc.validator;

# User Input parameters  
type InputFunc record {|
    
    anydata...;

|};

public type Input InputFunc|anydata[];

public isolated function responseObject(int requestId, any answer) returns validator:Response{
    validator:Response res={
        id: requestId,
        result: answer,
        jsonrpc: "2.0"
    };

    return res;
}


# Caller module Error
# + return - Return Value Description  
public isolated function parseError() returns validator:Error{
    
    validator:Error err ={
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
public isolated function methodNotFoundError(int requestId) returns validator:Error{
    validator:Error err ={
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
public isolated  function invalidMethodParams(int requestId) returns validator:Error{
    validator:Error err={
        id: requestId,
        err: {code: "-32602", message: "Invalid method parameters"},
        jsonrpc: "2.0"
    };

    return err;
}

# Caller module error 
# + return - Return Value Description  
public isolated  function serverError() returns validator:Error{
 
    validator:Error err = {
        id: null,
        err: {"code": "-32000", "message": "Server error"},
        jsonrpc: "2.0"
    };

    return err;
}

# Caller module error
# + return - Return Value Description  
public isolated  function invalidRequestError() returns validator:Error{
    validator:Error err = {
        id: null,
        err: {"code": "-32600", "message": "Invalid request"},
        jsonrpc: "2.0"
    };

    return err;
}