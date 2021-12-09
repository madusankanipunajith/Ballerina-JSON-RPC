
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


public type InputFunc record {|
    
    anydata...;

|};

public type Input InputFunc|anydata[];

public type Identy json|any[]|Error;

public type Method isolated function (Input) returns any|error;

public type Methods record {|
    Method...;
|};