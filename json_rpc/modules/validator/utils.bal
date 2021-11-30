public type JsonRecord record {|
    int id?;
    string method?;
    string result?;
    anydata params?;
    string jsonrpc;
    json err?;
|};

public type Response record {|
    int id;
    any result;
    string jsonrpc;
|};

public type Error record {|
    int? id;
    json err;
    string jsonrpc;
|};

public type Request record {
    int id;
    string method;
    anydata params;
    string jsonrpc;
};

public type Notification record {
    string method;
    anydata params;
    string jsonrpc;
};

public type JsonRPCTypes Request|Response|Error|Notification;

isolated function sendNotification(string method, anydata params) returns Notification{

    Notification notification={
        method:method,
        params:params,
        jsonrpc: "2.0"
    };
    
    return notification;
}

isolated function sendRequest(int id, string method, anydata params) returns Request{
    
    Request request ={
        id:id,
        method:method,
        params:params,
        jsonrpc: "2.0"
    };

    return request;
}

isolated function sendError(int? id, json err) returns Error{
    Error e ={
        id:id,
        err:err,
        jsonrpc:"2.0"
    };

    return e;
}

isolated function sendResponse(int id, any result) returns Response{
    Response response ={
        id:id,
        result:result,
        jsonrpc: "2.0"
    };

    return response;
}
