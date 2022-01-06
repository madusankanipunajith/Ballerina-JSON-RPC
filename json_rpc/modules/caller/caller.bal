import json_rpc.'types;
import json_rpc.util;

# Description
#
# + request - Parameter Description  
# + func - Parameter Description
# + return - Return Value Description  
public isolated function executor('types:Request|'types:Notification request, isolated function ('types:Input func) returns any|error func) returns 'types:Response|error|null{

    isolated function ('types:Input) returns any|error abstractFunction = func.clone();
    anydata parameters = request.params;
    'types:Input fetchedParameters;

    if parameters === () {

        json P = {data: null};

        fetchedParameters = check P.cloneWithType();

        any _ = check abstractFunction(fetchedParameters);    
            
            if request is 'types:Request {
             
                return util:responseObject(request.id, "success");      
            
            }else{

                return null;
            }

            
    }

    if parameters is anydata[]{

        fetchedParameters = parameters;
                   
    }else{
                    
        fetchedParameters = check parameters.cloneWithType(); 

            
    }

        any res = check abstractFunction(fetchedParameters);    if res is null {res = "success";}

        if request is 'types:Request{

            return util:responseObject(request.id, res);
        
        }else{
            
            return null;
        }
        

}





