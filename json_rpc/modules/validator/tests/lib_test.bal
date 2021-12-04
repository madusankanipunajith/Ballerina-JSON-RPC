import ballerina/test;
import ballerina/lang.value;
import json_rpc.'type;
@test:Config{}
function testJsonRequest() {
    string str = "{\"jsonrpc\":\"2.0\",\"method\":\"display\",\"params\":{\"number\":89, \"street\":\"main street\", \"town\":\"Colombo\"},\"id\":10}";
    json jsn = checkpanic value:fromJsonString(str);
    'type:JsonRPCTypes|error messageValidatorResult = messageValidator(jsn);
    
    boolean result = false;
    if messageValidatorResult is 'type:Request{
        result = true;
    }

    test:assertTrue(result, msg = "AssertTrue failed");

}

@test:Config{}
function testJsonResponse() {
    string str2 = "{\"id\":10,\"result\":\"this is the result came from server\",\"jsonrpc\":\"2.0\"}";
    json jsn = checkpanic value:fromJsonString(str2);
    'type:JsonRPCTypes|error messageValidatorResult = messageValidator(jsn);

    boolean result = false;
    if messageValidatorResult is 'type:Response{
        result = true;
    }

    test:assertTrue(result, msg = "AssertTrue failed");
}

@test:Config{}
function testJsonNotification() {
    string str9 = "{\"jsonrpc\":\"2.0\",\"method\":\"display\",\"params\":{\"number\":89, \"street\":\"main street\", \"town\":\"Colombo\"}}";
    json jsn = checkpanic value:fromJsonString(str9);
    'type:JsonRPCTypes|error messageValidatorResult = messageValidator(jsn);

    boolean result = false;
    if messageValidatorResult is 'type:Notification{
        result = true;
    }

    test:assertTrue(result, msg = "AssertTrue failed");
}

@test:Config{}
function testJsonError() {
    string str3 = "{\"jsonrpc\":\"2.0\",\"method\":\"display\",\"params\":{\"number\":89, \"street\":\"main street\", \"town\":\"Colombo\"}, \"s\":\"10\"}";
    string str5 = "{\"jsonrpc\": \"2.0\", \"error\": {\"code\": -32601, \"message\": \"Method not found\"}, \"id\":23}";
    json jsn = checkpanic value:fromJsonString(str3);
    json jsn2 = checkpanic value:fromJsonString(str5);
    'type:JsonRPCTypes|error messageValidatorResult = messageValidator(jsn);
    'type:JsonRPCTypes|error messageValidatorResult2 = messageValidator(jsn2);

    boolean result = false;
    boolean result2 = false;
    if messageValidatorResult is 'type:Error{
        result = true;
    }

    if messageValidatorResult2 is 'type:Error{
        result2 = true;
    }

    test:assertTrue(result, msg = "AssertTrue failed");
    test:assertTrue(result2, msg = "AssertTrue failed");
}

// @test:Config{}
// function testPanicError() {
//     string str2 = "{\"id\":10,\"result\":\"this is the result came from server\",\"jsonrpc\":\"2.0\"";
     
//     JsonRPCTypes|error messageValidatorResult = trap messageValidator(str2.toJson());

//     boolean result = false;
//     if messageValidatorResult is error{
//         result = true;
//     }

//     test:assertTrue(result, msg = "AssertTrue failed");    

// }