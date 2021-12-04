import json_rpc.validator;
import json_rpc.util;
import json_rpc.'type;

# Description
#
# + message - Parameter Description
# + return - Return Value Description  
public isolated function checker(json message) returns 'type:Error|'type:Request|null{
    'type:JsonRPCTypes result = validator:messageValidator(message);

    if result is 'type:Error{
        return result;
    }

    if result is 'type:Request{
        anydata reqestParams = result.params;

        if( !(reqestParams is anydata[]) && !(reqestParams is map<anydata>) && !(reqestParams === ())){
                    
            return util:invalidMethodParams(result.id);       
        }

        return result;
    }

    // if it is a response or something else
    return null;
}