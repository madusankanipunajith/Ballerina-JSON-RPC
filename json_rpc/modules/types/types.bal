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

public type JsonRPCTypes Request|Response|Error|Notification;

public type InputParams json|anydata[];

public type RequestType json|any[]|Error;

public type Method isolated function (InputParams) returns any|error;

public type Methods record {|
    isolated function (InputParams) returns any|error...;
|};

public type JRPCResponse Response|Error|JsonRPCTypes?[]|();

public type BatchJRPCOutput JsonRPCTypes?[];

public type SingleJRPCOutput Response|Error;

public type TCPConfig record {|
    string tcpRemoteHost;
    int tcpRemotePort;
|};

public type UDPConfig record {|
    string udpRemoteHost;
    int udpRemotePort;
|};

public type WSConfig record {|
    string wsRemoteHost;
    int wsRemotePort;
    string path = "";
|};

