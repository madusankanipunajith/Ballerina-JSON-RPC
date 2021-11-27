import json_rpc.validator;
import ballerina/lang.value;
import json_rpc.store;



# Description
#
# + request - Parameter Description  
# + func - Parameter Description
# + return - Return Value Description  
public function executor(validator:Request request, function (store:InputFunc func) returns any|error func) returns validator:Response|error|null{

    function (store:InputFunc) returns any|error abstractFunction = func.clone();
    anydata parameters = request.params;
    store:InputFunc fetchedParameters;

    if parameters === () {

        json P = {data: null};

        fetchedParameters = check P.cloneWithType();

        any _ = check abstractFunction(fetchedParameters);    
            
            return null; 
            
    }

    if parameters is anydata[]{

        json convertToJson = check value:fromJsonString(parameters.toString());
                    
        json M ={ arr: convertToJson};

        fetchedParameters = check M.cloneWithType();
                   
    }else{
                    
        fetchedParameters = check parameters.cloneWithType();     
            
    }

        any res = check abstractFunction(fetchedParameters);

        return store:responseObject(request.id, res);

}





