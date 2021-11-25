// import ballerina/test;
// import json_rpc.validator;

// validator:Error res1 ={
//     id: null,
//     err:{"code": "-32700", "message": "Parse error"},
//     jsonrpc: "2.0"
// };

// validator:Error res2 ={
//     id: null,
//     err:{"code": "-32600", "message": "something went wrong in message conversion or Invalid request"},
//     jsonrpc: "2.0"
// };

// validator:Error res3 ={
//     id: 10,
//     err:{code: "-32601", message: "method is not found"},
//     jsonrpc: "2.0"
// };

// validator:Error res4 ={
//     id: 10,
//     err:{code: "-32602", message: "Invalid method parameters"},
//     jsonrpc: "2.0"
// };

// @test:Config{}
// function testParseError() returns error? {
//     string str2 = "{\"id\":10,\"result\":\"this is the result came from server\",\"jsonrpc\":\"2.0\"";
//     validator:Error|validator:Response|BatchResponse|error? executorResult = executor(str2);

//     if executorResult is validator:Error{
//         test:assertEquals(executorResult, res1, msg = "Testing has been failed");
//     }else{
//         test:assertFalse(true, msg = "AssertFalse failed");
//     }
// }

// @test:Config{}
// function testInvalidRequestError() {
//     string str3 = "{\"jsonrpc\":\"2.0\",\"method\":\"display\",\"params\":{\"number\":89, \"street\":\"main street\", \"town\":\"Colombo\"}, \"s\":\"10\"}";
//     validator:Error|validator:Response|BatchResponse|error? executorResult = executor(str3);

//     if executorResult is validator:Error{
//         test:assertEquals(executorResult, res2, msg = "Testing has been failed");
//     }else{
//         test:assertFalse(true, msg = "AssertFalse failed");
//     }
// }

// // There is no main method in the module namespace. therefore there is no methods are added
// // due to that this test is failed 
// @test:Config{}
// function testInvalidMethodParameters() {
//     string str5 = "{\"jsonrpc\":\"2.0\",\"method\":\"add\",\"params\":550,\"id\":10}";
//     validator:Error|validator:Response|BatchResponse|error? executorResult = executor(str5);

//     if executorResult is validator:Error{
//         test:assertNotEquals(executorResult, res4, msg = "Testing has been failed");
//     }else{
//         test:assertFalse(true, msg = "AssertFalse failed");
//     }
// }

// @test:Config{}
// function testMethodNotFoundError() {
//     string str = "{\"jsonrpc\":\"2.0\",\"method\":\"adds\",\"params\":{\"x\":89, \"y\":100},\"id\":10}";
//     validator:Error|validator:Response|BatchResponse|error? executorResult = executor(str);

//     if executorResult is validator:Error{
//         test:assertEquals(executorResult, res3, msg = "Testing has been failed");
//     }else{
//         test:assertFalse(true, msg = "AssertFalse failed");
//     }
// }

