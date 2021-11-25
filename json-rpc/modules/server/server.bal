import json_rpc.store;
import json_rpc.validator;
import json_rpc.runner;


# Request parameters of the JSON message are filtered and stored  
public type InputFunc record {|
    
    anydata...;

|};

type serExecutor function(string message, map<function (store:InputFunc func) returns any|error> serMapper) returns validator:Error | validator:Response | runner:BatchResponse | error?;


public class Server {
    // private access
    private map<function (InputFunc func) returns any|error> methodMapper = {};
    private serExecutor serverExecutor;

    private function addFunction(string method, function (store:InputFunc) returns any|error servFunc) returns error?{
        
        
            
            if (self.methodMapper[method] is null) {
                
                self.methodMapper[method] =  servFunc.clone();     
    
            }else{

                return error("same request method name cannot be applied...");
            }
        
    }

    public function init() {
        self.serverExecutor = runner:executor;  
    }

    public function serverFunction(string method, function (store:InputFunc) returns any|error servFunc){
        
        checkpanic self.addFunction(method,servFunc);
    }

    public function messageCatcher(string message) returns validator:Error | validator:Response | runner:BatchResponse | error?{
        //return self.serverExecutor(message, self.methodMapper);

        return runner:executor(message, self.methodMapper);

    }
}





