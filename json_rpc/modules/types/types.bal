public type JsonRecord record {|
    int? id?;
    string method?;
    anydata result?;
    anydata params?;
    string jsonrpc = "2.0";
    json err?;
|};

public type Response record {|
    int id;
    anydata result;
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
    string jsonrpc = "2.0";
};

public type Notification record {
    string method;
    anydata params;
    string jsonrpc = "2.0";
};

public type Batch Request|Notification[];

public type JsonRPCTypes Request|Response|Error|Notification;


public type InputFunc record {|
    
    anydata...;

|};

public type Input InputFunc|anydata[];

public type Identy json|any[]|Error;

public type Method isolated function (Input) returns any|error;

public type Methods record {|
    isolated function (Input) returns any|error...;
|};

public type JRPCResponse Response|Error|JsonRPCTypes?[]|();

public class JRPCMethods {

    public isolated function getMethods() returns Methods{
        return {};
    }

}

