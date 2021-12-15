import json_rpc.server;
import json_rpc.'type;
import ballerina/io;

string str = "{\"jsonrpc\":\"2.0\",\"method\":\"add\",\"params\":{\"x\":89, \"y\":100},\"id\":10}";
string str2 = "{\"foo\": \"boo\"}";
string str3 = "[{\"jsonrpc\":\"2.0\",\"method\":\"add\",\"params\":{\"x\":89, \"y\":100},\"id\":10}, {\"jsonrpc\":\"2.0\",\"method\":\"sub\",\"params\":{\"x\":89, \"y\":100},\"id\":10}]";
string str4 = "{\"jsonrpc\":\"2.0\",\"method\":\"mult\",\"params\":[10,20,30],\"id\":10}";
string str5 = "{\"jsonrpc\":\"2.0\",\"method\":\"print\",\"id\":10}";
string str60 = "{\"jsonrpc\":\"2.0\",\"method\":\"add\",\"params\":100,\"id\":10}";
string str6 = "[]";

type Nip record {|
    int x;
    int y;
|};

public function main() {
   
    Calculator calc = new();
    server:Server s1 = new(calc);
    io:println(s1.runner(str3));

}

class Calculator{
  *server:JRPCService;

    function init() {
      CalcMethods cmethods = new();
      self.methods = cmethods;
    }

    public isolated function name() returns string|error {
        return "calculator";
    }

}


isolated class CalcMethods {
  *'type:JRPCMethods;

    isolated function addFunction(server:Input ifs) returns int|error{
      Nip nip = check ifs.cloneWithType();
      return nip.x + nip.y;
    }

    isolated function subFunction(server:Input ifs) returns int|error{
      Nip nip = check ifs.cloneWithType();
      return nip.x - nip.y;
    }
    
    public isolated function getMethods() returns 'type:Methods{

        'type:Methods meth={
          "add": self.addFunction,
          "sub": self.subFunction
        };

        return meth;
    }    

}





