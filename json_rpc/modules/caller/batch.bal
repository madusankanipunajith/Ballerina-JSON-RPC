import ballerina/lang.value;
import json_rpc.store;

# Description
#
# + requestMessage - Parameter Description
# + return - Return Value Description  
public isolated function requestIdentifier(string requestMessage) returns store:Identy{

    any|error fetchMessage = trap value:fromJsonString(requestMessage);

    if fetchMessage is any[]{

        if fetchMessage.length() === 0{
            return store:invalidRequestError();
        }else{
            return fetchMessage;
        }
       
    }

    if fetchMessage is error{
        return store:parseError();
    }

    if fetchMessage is json{
        return fetchMessage;
    }

    return store:invalidRequestError();
}