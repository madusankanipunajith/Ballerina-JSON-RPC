import json_rpc.'type;
import json_rpc.util;

# Description
#
# + request - Parameter Description  
# + func - Parameter Description
# + return - Return Value Description  
public isolated function executor('type:Request request, isolated function ('type:Input func) returns any|error func) returns 'type:Response|error|null{

    isolated function ('type:Input) returns any|error abstractFunction = func.clone();
    anydata parameters = request.params;
    'type:Input fetchedParameters;

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

        return util:responseObject(request.id, res);

}





