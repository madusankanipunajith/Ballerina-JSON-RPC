import ballerina/lang.value;
import json_rpc.'types;
import json_rpc.util;

# Identify that the request message is a single message or batch message
# If it can't convirt the string message it genatrates parse error
# If the identified message is different from the expected types it will give invalid request error  
#
# + requestMessage - string type request message
# + return - Return the identity of the request message  
public isolated function requestIdentifier(string requestMessage) returns 'types:Identy {

    any|error fetchMessage = trap value:fromJsonString(requestMessage);
    if fetchMessage is any[] {
        if fetchMessage.length() === 0 {
            return util:invalidRequestError();
        } else {
            return fetchMessage;
        }
    }

    if fetchMessage is error {
        return util:parseError();
    }

    if fetchMessage is json {
        return fetchMessage;
    }

    return util:invalidRequestError();
}
