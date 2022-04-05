import ballerina/websocket;
import ballerina/udp;
import ballerina/tcp;
public type JsonRecord record {|
    int? id?;
    string method?;
    anydata result?;
    anydata params?;
    string jsonrpc = "2.0";
    json err?;
|};

# structure of Json rpc response message
#
# + id - unique id  
# + result - stores the output of the request message's execution  
# + jsonrpc - 2.0 version
public type Response record {|
    int id;
    anydata result;
    string jsonrpc = "2.0";
|};

# structure of Json rpc error message
#
# + id - unique id and could be null  
# + err - error message  
# + jsonrpc - 2.0 version
public type Error record {|
    int? id;
    json err;
    string jsonrpc = "2.0";
|};

# structure of Json rpc request message
#
# + id - unique id   
# + method - method's name  
# + params - parameters and could be json or any[]  
# + jsonrpc - 2.0 version
public type Request record {
    int id;
    string method;
    anydata params;
    string jsonrpc = "2.0";
};

# structure of Json rpc notification message
#
# + method - method's name  
# + params - parameters and could be json or any[]  
# + jsonrpc - 2.0 version
public type Notification record {
    string method;
    anydata params;
    string jsonrpc = "2.0";
};

# Union of Request,Response,Error and Notification
public type JRPCTypes Request|Response|Error|Notification;

# Union of json,Array of anydata and nil
public type InputParams json|anydata[]|();

# Union if json,Array of any type and Error
public type RequestType json|any[]|Error;

# User defined method in the server side
public type Method  function (InputParams) returns any|error;

# Record of Method data type (user defined functions)
public type Methods record {|
    function (InputParams) returns any|error...;
|};

# Union of Response,Error,Array of JRPCTypes and nil
public type JRPCResponse Response|Error|JRPCTypes?[]|();

# It is just an Array of JRPCTypes
public type BatchJRPCOutput JRPCTypes?[];

# Union of Response and Error
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

# Configuration of the tcp protocol
#
# + tcpRemoteHost - remote host (localhost)  
# + tcpRemotePort - remote port  
# + security - TLS security (optional)
public type TCPConfig record {|
    string tcpRemoteHost;
    int tcpRemotePort;
    tcp:ClientConfiguration security?;
|};

# Configuration of the udp protocol
#
# + udpRemoteHost - remote host (localhost)  
# + udpRemotePort - remote port  
# + security - TLS security (optional)
public type UDPConfig record {|
    string udpRemoteHost;
    int udpRemotePort;
    udp:ConnectClientConfiguration security?;
|};

# Configuration of the udp protocol
#
# + wsRemoteHost - remote host (localhost)  
# + wsRemotePort - remote port  
# + security - TLS security (optional)
public type WSConfig record {|
    string wsRemoteHost;
    int wsRemotePort;
    websocket:ClientConfiguration security?;
|};