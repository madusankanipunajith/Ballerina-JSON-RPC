import ballerina/test;
import json_rpc.types;

@test:Config{}
public function testRequestIdentifierInvalidRequest() {
    types:RequestType requestIdentifierResult = fetchRequest(str6);
    test:assertEquals(<types:Error>requestIdentifierResult, res4, msg = "Testing has been failed");
}

@test:Config{}
public function testRequestIdentifierParseError() {
    types:RequestType requestIdentifierResult = fetchRequest(str4);
    test:assertEquals(<types:Error>requestIdentifierResult, res1, msg = "Testing has been failed");
}

@test:Config{}
public function testRequestIdentifierJsonType() {
    types:RequestType requestIdentifierResult = fetchRequest(str2);
    boolean result = false;

    if requestIdentifierResult is json{
        result = true;
    }
    test:assertTrue(result, msg = "Testing has been failed");
}

@test:Config{}
public function testRequestIdentifierBatchType() {
    types:RequestType requestIdentifierResult = fetchRequest(str3);
    boolean result = false;

    if requestIdentifierResult is any[]{
        result = true;
    }
    test:assertTrue(result, msg = "Testing has been failed");
}