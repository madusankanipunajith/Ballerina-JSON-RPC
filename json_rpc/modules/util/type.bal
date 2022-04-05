import ballerina/websocket;
import ballerina/tcp;
import json_rpc.types;
import ballerina/udp;

# Union of websocket caller, tcp caller and udp caller
public type Jcaller websocket:Caller|tcp:Caller|udp:Caller;

# Union if TCPConfig,UDPConfig,WSConfig
public type Config types:TCPConfig|types:UDPConfig|types:WSConfig;