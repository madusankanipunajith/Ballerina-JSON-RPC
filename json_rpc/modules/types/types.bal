public type JsonRecord record {|
    int? id?;
    string method?;
    anydata result?;
    anydata params?;
    string jsonrpc = "2.0";
    json err?;
|};

# Description
#
# + id - Field Description  
# + result - Field Description  
# + jsonrpc - Field Description
public type Response record {|
    int id;
    anydata result;
    string jsonrpc = "2.0";
|};

# Description
#
# + id - Field Description  
# + err - Field Description  
# + jsonrpc - Field Description
public type Error record {|
    int? id;
    json err;
    string jsonrpc = "2.0";
|};

# Description
#
# + id - Field Description   
# + method - Field Description  
# + params - Field Description  
# + jsonrpc - Field Description
public type Request record {
    int id;
    string method;
    anydata params;
    string jsonrpc = "2.0";
};

# Description
#
# + method - Field Description  
# + params - Field Description  
# + jsonrpc - Field Description
public type Notification record {
    string method;
    anydata params;
    string jsonrpc = "2.0";
};

public type JRPCTypes Request|Response|Error|Notification;

public type InputParams json|anydata[];

public type RequestType json|any[]|Error;

public type Method isolated function (InputParams) returns any|error;

public type Methods record {|
    isolated function (InputParams) returns any|error...;
|};

public type JRPCResponse Response|Error|JRPCTypes?[]|();

public type BatchJRPCOutput JRPCTypes?[];

public type SingleJRPCOutput Response|Error;

# Parameter type of batch methods (sendBatchRequest, sendBatchNotification)
#
# + notification - Boolean attribute which is used to identify message is request or notification  
# + method - Define the method of the message   
# + params - Define the parameters of the message
public type BatchInput record {|
    boolean notification = false;
    string method;
    anydata params;
|};