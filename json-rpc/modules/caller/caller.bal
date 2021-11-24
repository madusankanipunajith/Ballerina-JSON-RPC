import json_rpc.validator;
import json_rpc.store;
import json_rpc.method_handler;
import ballerina/io;
import ballerina/lang.value;

public function caller(string message) returns validator:JsonRPCTypes?|error{

    validator:JsonRPCTypes|error result = trap validator:messageValidator(message);

    if result is error{
        validator:Error err ={
            id: null,
            err: {"code": "-32700", "message": "Parse error"},
            jsonrpc: "2.0" 
        };

        return err;
    
    }else {

        if result is validator:Request{

            if(method_handler:methMap.findMethod(result.method)){
                
                // method is not found
                validator:Error err ={
                    id: result.id,
                    err: {code: "-32601", message: "method is not found"},
                    jsonrpc: "2.0"
                };

                return err;
            
            }else{

                //function (store:InputFunc) returns any|error get = store:methodMapper.get(result.method);
                function (store:InputFunc) returns any|error get = method_handler:methMap.getMethod(result.method);
                anydata params = result.params;
                
                store:InputFunc param;
                //io:println(typeof params);

                if( !(params is anydata[]) && !(params is map<anydata>)){
                    
                    validator:Error err={
                        id: result.id,
                        err: {code: "-32602", message: "Invalid method parameters"},
                        jsonrpc: "2.0"
                    };

                    return err;
                }

                if params is anydata[]{
                    json convertToJson = check value:fromJsonString(params.toString());
                    json madu ={
                        arr: convertToJson
                    };

                    param = check madu.cloneWithType();
                   
                }else{
                    
                    param = check params.cloneWithType();     
                }

                any res = check get(param);
                

                    validator:Response response = {
                        id: result.id,
                        result: res,
                        jsonrpc: "2.0"
                    };

                    return response;
                }

        }
   
        io:println();
        if result is validator:Error{
            return result;
        }  

    }

    // swanlake beta4 support
    return;
}
