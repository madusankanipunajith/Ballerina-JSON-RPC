import ballerina/test;
import json_rpc.types;
import ballerina/io;
import ballerina/lang.value;

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

@test:BeforeEach
public function startTesting() {
    io:println("Testing is starting...");
}

@test:Config{}
public function testRequestIdentifierInvalidRequest() {
    types:Identy requestIdentifierResult = requestIdentifier(str6);
    test:assertEquals(<types:Error>requestIdentifierResult, res4, msg = "Testing has been failed");
}

@test:Config{}
public function testRequestIdentifierParseError() {
    types:Identy requestIdentifierResult = requestIdentifier(str4);
    test:assertEquals(<types:Error>requestIdentifierResult, res1, msg = "Testing has been failed");
}

@test:Config{}
public function testRequestIdentifierJsonType() {
    types:Identy requestIdentifierResult = requestIdentifier(str2);
    boolean result = false;

    if requestIdentifierResult is json{
        result = true;
    }
    test:assertTrue(result, msg = "Testing has been failed");
}

@test:Config{}
public function testRequestIdentifierBatchType() {
    types:Identy requestIdentifierResult = requestIdentifier(str3);
    boolean result = false;

    if requestIdentifierResult is any[]{
        result = true;
    }
    test:assertTrue(result, msg = "Testing has been failed");
}

@test:Config{}
public function testCheckerInvalidParameters() {
    json jsn = checkpanic value:fromJsonString(str60);
    types:Error|types:Request|types:Notification|null checkerResult = checker(jsn);
    test:assertEquals(<types:Error>checkerResult, res3, msg = "Testing has been failed");
}

@test:Config{}
public function testCheckerInvalidTypeConversion() {
    json jsn = checkpanic value:fromJsonString(str60);
    types:Error|types:Request|types:Notification|null checkerResult = checker(jsn);
    test:assertEquals(<types:Error>checkerResult, res3, msg = "Testing has been failed");
}

@test:Config{}
public function testCheckerInvalidNotificationParams() {
    json jsn = checkpanic value:fromJsonString(str8);
    types:Error|types:Request|types:Notification|null checkerResult = checker(jsn);
    test:assertEquals(checkerResult, null, msg = "Testing has been failed");
}

@test:Config{}
public function testCheckerNotification() {
    boolean result = false;
    json jsn = checkpanic value:fromJsonString(str5);
    types:Error|types:Request|types:Notification|null checkerResult = checker(jsn);
    if checkerResult is types:Notification{
        result = true;
    }
    test:assertTrue(result, msg = "Testing has been failed");
}

@test:Config{}
public function testCheckerRequest() {
    boolean result = false;
    json jsn = checkpanic value:fromJsonString(str);
    types:Error|types:Request|types:Notification|null checkerResult = checker(jsn);
    if checkerResult is types:Request{
        result = true;
    }
    test:assertTrue(result, msg = "Testing has been failed");
}

@test:Config{}
public function callerExecuteFunction(){
    types:Response|error|null executorResult = executor(r, addFunction);
    test:assertEquals(executorResult, res5, msg = "Testing has been failed");
}


























// @test:Config{}
// public function checkerTest() {
//     validator:Error|validator:Request|null result = checker(str5);
//     validator:Error|validator:Request|null result2 = checker(str2);
//     validator:Error|validator:Request|null result3 = checker(str8);
//     validator:Error|validator:Request|null result4 = checker(str60);
//     validator:Error|validator:Request|null result5 = checker(str);

//     test:assertEquals(result, res1, msg = "Testing has been failed");
//     test:assertEquals(result2, res2, msg = "Testing has been failed");
//     test:assertEquals(result3, null, msg = "Testing has been failed");
//     test:assertEquals(result4, res3, msg = "Testing has been failed");
//     test:assertEquals(result5, res4, msg = "Testing has been failed");
// }

// @test:Config{}
// public function batchCheckerTest() {
//     int result = batchChecker(str6);
//     test:assertEquals(result, 0, msg = "Testing has been failed");

//     int result2 = batchChecker(str);
//     test:assertEquals(result2, 3, msg = "Testing has been failed");

//     int result3 = batchChecker(str3);
//     test:assertEquals(result3, 1, msg = "Testing has been failed");

//     int result4 = batchChecker(str5);
//     test:assertEquals(result4, 2, msg = "Testing has been failed");
// }