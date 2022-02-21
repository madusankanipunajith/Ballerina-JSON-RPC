import ballerina/websocket;
import ballerina/tcp;
import json_rpc.types;
import ballerina/udp;
public type Jcaller websocket:Caller|tcp:Caller|udp:Caller;

public type Config types:TCPConfig|types:UDPConfig|types:WSConfig;