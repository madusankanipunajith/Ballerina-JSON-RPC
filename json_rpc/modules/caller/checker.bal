import json_rpc.validator;
import json_rpc.util;
import json_rpc.'types;

# Description
#
# + message - Parameter Description
# + return - Return Value Description  
public isolated function checker(json message) returns 'types:Error|'types:Request|null{
    'types:JsonRPCTypes result = validator:messageValidator(message);

    if result is 'types:Error{
        return result;
    }

    if result is 'types:Request{
        anydata reqestParams = result.params;

        if( !(reqestParams is anydata[]) && !(reqestParams is map<anydata>) && !(reqestParams === ())){
                    
            return util:invalidMethodParams(result.id);       
        }

        return result;
    }

    // if it is a response or something else
    return null;
}