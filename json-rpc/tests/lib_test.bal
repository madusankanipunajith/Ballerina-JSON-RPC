import ballerina/test;
import ballerina/io;
import json_rpc.validator;
import json_rpc.runner;
import json_rpc.server;

string str6 = "{\"jsonrpc\":\"2.0\",\"method\":\"mult\",\"params\":550,\"id\":10";
string str7 = "{\"jsonrpc\":\"2.0\",\"method\":\"adds\",\"params\":{\"x\":89, \"y\":100},\"id\":10}";
string str8 = "{\"jsonrpc\":\"2.0\",\"method\":\"add\",\"params\":550,\"id\":10}";
string str9 = "{\"foo\": \"boo\"}";

validator:Error res1 ={
    id: null,
    err:{"code": "-32700", "message": "Parse error"},
    jsonrpc: "2.0"
};

validator:Error res2 ={
    id: null,
    err:{"code": "-32600", "message": "something went wrong in message conversion or Invalid request"},
    jsonrpc: "2.0"
};

validator:Error res3 ={
    id: 10,
    err:{code: "-32601", message: "method is not found"},
    jsonrpc: "2.0"
};

validator:Error res4 ={
    id: 10,
    err:{code: "-32602", message: "Invalid method parameters"},
    jsonrpc: "2.0"
};

function init(){
    io:println("testing on json_rpc package");
}

@test:Config{
    before: init
}
function parseErrorTest() {
    server:Server madusanka = new();
    validator:Error|validator:Response|runner:BatchResponse|error? result = madusanka.messageCatcher(str6);
    
    if result is validator:Error{
        test:assertEquals(result, res1, msg = "Testing has been failed");
    }else{
        test:assertFalse(true, msg = "AssertFalse failed");
    }
}

@test:Config{}
function methodIsNotFoundErrorTest() {
    server:Server nadeeshan = new();
    nadeeshan.serverFunction("add", addFunction);
    validator:Error|validator:Response|runner:BatchResponse|error? result = nadeeshan.messageCatcher(str7);

    if result is validator:Error{
        test:assertEquals(result, res3, msg = "Testing has been failed");
    }else{
        test:assertFalse(true, msg = "AssertFalse failed");
    }
}

@test:Config{}
function invalidMethodParameterErrorTest() {
    server:Server nadeeshan = new();
    nadeeshan.serverFunction("add", addFunction);
    validator:Error|validator:Response|runner:BatchResponse|error? result = nadeeshan.messageCatcher(str8);

    if result is validator:Error{
        test:assertEquals(result, res4, msg = "Testing has been failed");
    }else{
        test:assertFalse(true, msg = "AssertFalse failed");
    }
}

@test:Config{}
function invalidRequestTest() {
    server:Server dulaj = new();
    dulaj.serverFunction("add", addFunction);
    validator:Error|validator:Response|runner:BatchResponse|error? result = dulaj.messageCatcher(str9);

    if result is validator:Error{
        test:assertEquals(result, res2, msg = "Testing has been failed");
    }else{
        test:assertFalse(true, msg = "AssertFalse failed");
    }
}