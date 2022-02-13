import json_rpc.'types;
import json_rpc.util;


# Executes the input function and fetches the oputput of the function
#
# + request - jrpc request message according to the jrpc specification (valid attributes)
# + func - filtered method (output of the method filter function)
# + return - Return jrpc response/error/nil  
public isolated function execute('types:Request|'types:Notification request, isolated function ('types:Input func) returns any|error func) returns 'types:Response|error|() {

    isolated function ('types:Input) returns any|error abstractFunction = func.clone();
    anydata parameters = request.params;
    'types:Input fetchedParameters;

    // check empty parameters
    if parameters === () {
        json P = {data: null};
        fetchedParameters = check P.cloneWithType();

        any _ = check abstractFunction(fetchedParameters);
        if request is 'types:Request {
            return util:responseObject(request.id, SUCCESS);
        } else {
            return null;
        }
    }

    //check array type parameters and json type
    if parameters is anydata[] {
        fetchedParameters = parameters;
    } else {
        fetchedParameters = check parameters.cloneWithType();
    }

    // execute the request/notification message
    any res = check abstractFunction(fetchedParameters);
    if res is null {
        res = SUCCESS;
    }

    if request is 'types:Request {
        return util:responseObject(request.id, res);
    } else {
        return ();
    }
}