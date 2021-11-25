// import ballerina/test;
// import json_rpc.validator;
// import json_rpc.server;

// type Nip record {|
//     int x;
//     int y;
// |};

// public function addFunction(server:InputFunc ifs) returns int|error{
//     json nips = <json> ifs;
//     Nip nip = check nips.cloneWithType();
//     return nip.x + nip.y;
// }

// public function subFunction(server:InputFunc ifs) returns int|error{
//     json nips = <json> ifs;
//     Nip nip = check nips.cloneWithType();
//     return nip.x - nip.y;
// }

// // json rpc messages come from client
// string str = "{\"jsonrpc\":\"2.0\",\"method\":\"add\",\"params\":{\"x\":89, \"y\":100},\"id\":10}";
// string str2 = "{\"foo\": \"boo\"}";
// string str3 = "[{\"jsonrpc\":\"2.0\",\"method\":\"add\",\"params\":{\"x\":89, \"y\":100},\"id\":10}, {\"jsonrpc\":\"2.0\",\"method\":\"sub\",\"params\":{\"x\":89, \"y\":100},\"id\":10}]";
// string str4 = "{\"jsonrpc\":\"2.0\",\"method\":\"mult\",\"params\":[10,20,30],\"id\":10}";
// string str5 = "{\"jsonrpc\":\"2.0\",\"method\":\"mult\",\"params\":550,\"id\":10}";

// validator:Error|validator:Response|BatchResponse|error? executorResult = null;

// @test:BeforeSuite
// function beforeFunc() {    
//     server:Server madusanka = new();
//     madusanka.serverFunction("add", addFunction);
//     madusanka.serverFunction("sub", subFunction);
//     executorResult = madusanka.messageCatcher(str2);
// }

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
//    validator:Error|validator:Response|BatchResponse|error? result = executorResult;
//     if result is validator:Error{
//         test:assertEquals(result, res1, msg = "Testing has been failed");
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
