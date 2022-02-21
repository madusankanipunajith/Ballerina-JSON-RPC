import ballerina/websocket;
import ballerina/tcp;
import ballerina/udp;
public type Jcaller websocket:Caller|tcp:Caller|udp:Caller;

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