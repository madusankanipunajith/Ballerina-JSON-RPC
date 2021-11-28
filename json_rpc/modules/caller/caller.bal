import json_rpc.validator;
import json_rpc.store;


# Description
#
# + request - Parameter Description  
# + func - Parameter Description
# + return - Return Value Description  
public function executor(validator:Request request, function (store:Input func) returns any|error func) returns validator:Response|error|null{

    function (store:Input) returns any|error abstractFunction = func.clone();
    anydata parameters = request.params;
    store:Input fetchedParameters;

    if parameters === () {

        json P = {data: null};

        fetchedParameters = check P.cloneWithType();

        any _ = check abstractFunction(fetchedParameters);    
            
            return null; 
            
    }

    if parameters is anydata[]{

        fetchedParameters = parameters;
                   
    }else{
                    
        fetchedParameters = check parameters.cloneWithType(); 

            
    }

        any res = check abstractFunction(fetchedParameters);

        return store:responseObject(request.id, res);

}





