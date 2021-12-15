import ballerina/lang.value;
import json_rpc.'types;
import json_rpc.util;

# Description
#
# + requestMessage - Parameter Description
# + return - Return Value Description  
public isolated function requestIdentifier(string requestMessage) returns 'types:Identy{

    any|error fetchMessage = trap value:fromJsonString(requestMessage);

    if fetchMessage is any[]{

        if fetchMessage.length() === 0{
            return util:invalidRequestError();
        }else{
            return fetchMessage;
        }
       
    }

    if fetchMessage is error{
        return util:parseError();
    }

    if fetchMessage is json{
        return fetchMessage;
    }

    return util:invalidRequestError();
}