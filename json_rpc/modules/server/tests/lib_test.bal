import ballerina/test;
import json_rpc.types;

type Nip record {|
    int x;
    int y;
|};

public isolated function addFunction(types:Input ifs) returns int|error{
  Nip nip = check ifs.cloneWithType();
  return nip.x + nip.y;
}

types:Request r={
    id: 10,
    params: {"x": 100, "y":89},
    method: "add",
    jsonrpc: "2.0"
};

string str = "{\"jsonrpc\":\"2.0\",\"method\":\"add\",\"params\":{\"x\":89, \"y\":100},\"id\":10}";
string str2 = "{\"foo\": \"boo\"}";
string str3 = "[{\"jsonrpc\":\"2.0\",\"method\":\"add\",\"params\":{\"x\":89, \"y\":100},\"id\":10}, {\"jsonrpc\":\"2.0\",\"method\":\"sub\",\"params\":{\"x\":89, \"y\":100},\"id\":10}]";
string str4 = "{\"jsonrpc\":\"2.0\",\"method\":\"mult\",\"params\":[10,20,30],\"id\":10";
string str5 = "{\"jsonrpc\":\"2.0\",\"method\":\"print\"}";
string str6 = "[]";
string str60 = "{\"jsonrpc\":\"2.0\",\"method\":\"add\",\"params\":100,\"id\":10}";

string str7 = "{\"id\":10,\"result\":189,\"jsonrpc\":\"2.0\"}";
string str8 = "{\"jsonrpc\":\"2.0\",\"method\":\"add\",\"params\":100}";
string str9 = "[1]";


types:Error res1 ={
    id: null,
    err:{"code": "-32700", "message": "Parse error"},
    jsonrpc: "2.0"
};

types:Error res2 ={
    id: null,
    err:{"code": "-32600", "message": "something went wrong in message conversion or Invalid request"},
    jsonrpc: "2.0"
};

types:Error res3 ={
    id: 10,
    err:{code: "-32602", message: "Invalid method parameters"},
    jsonrpc: "2.0"
};

types:Error res4 ={
    id: null,
    err:{code: "-32600", message: "Invalid request"},
    jsonrpc: "2.0"
};

types:Response res5={
    id: 10,
    result: 189,
    jsonrpc: "2.0" 
};

@test:Config{}
public function callerExecuteFunction(){
    types:Response|error|null executorResult = execute(r, addFunction);
    test:assertEquals(executorResult, res5, msg = "Testing has been failed");
}
