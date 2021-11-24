import json_rpc.method_handler;
import json_rpc.store;
import json_rpc.validator;
import json_rpc.runner;

# Request parameters of the JSON message are filtered and stored  
public type InputFunc record {|
    
    anydata...;

|};

public function serverFunction(string method, function (store:InputFunc) returns any|error servFunc){
    checkpanic method_handler:addFunction(method, servFunc);
}

public function messageCatcher(string message) returns validator:Error | validator:Response | runner:BatchResponse | error?{
    return runner:executor(message);
}





