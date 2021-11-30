import json_rpc.caller;
import json_rpc.validator;
import json_rpc.store;

type MapFunctionType isolated function (store:Input) returns any|error;
type BatchResponse validator:JsonRPCTypes?[]; 

# User Input parameters  
type InputFunc record {|
    
    anydata...;

|};

public type Input InputFunc|anydata[];

public isolated class Server {
    private map<isolated function (store:Input func) returns any|error> methodMapper = {};

    private isolated function addFunction(string method,isolated function (store:Input) returns any|error servFunc) returns error?{
                  
            lock {
                
                if (self.methodMapper[method] is null) {
                
                    self.methodMapper[method] =  servFunc.clone();     
    
                }else{

                    return error("same request method name cannot be applied...");
                }

            }
        
    }

    private isolated function methodFilter(json message) returns MapFunctionType?{
        validator:JsonRPCTypes result = validator:messageValidator(message);

        if result is validator:Request{
            string method = result.method;

            lock {
                if !(self.methodMapper[method] is null){
                    return self.methodMapper[method];
                }
            }
        }

        return null; 
    }

    private isolated function executeSingleJson(json message) returns validator:Error|validator:Response?{
        validator:Request|validator:Error|null output = caller:checker(message);

        if output is validator:Request{
            MapFunctionType? mf = self.methodFilter(message);

            if mf is null{
                return store:methodNotFoundError(output.id);
            }

            return checkpanic caller:executor(output, mf);
        }

        else if output is validator:Error {
            return output;
        }

        else {
            return null; 
        }

    }

    private isolated function executeBatchJson(json[] message) returns BatchResponse{
        BatchResponse batch_res_array = [];

            foreach var item in message {
               
                batch_res_array.push(self.executeSingleJson(item));
               
            }

            return batch_res_array;
        

    }

    public isolated function runner(string message) returns validator:JsonRPCTypes|BatchResponse?{
       
        store:Identy identity = caller:requestIdentifier(message);

        if identity is validator:Error{
            return identity;
        }

        if identity is map<json>{
            return self.executeSingleJson(identity);
        }   

        if identity is json[]{
            return self.executeBatchJson(identity);
        }

        return store:serverError();
    }

    public isolated function serverFunction(string method, isolated function (store:Input) returns any|error servFunc){
        
        checkpanic self.addFunction(method,servFunc);
    }
}