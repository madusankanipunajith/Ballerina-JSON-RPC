import ballerina/lang.value;
import json_rpc.'types;

# Identify that the request message is a single message or batch message
# If it can't convirt the string message it genatrates parse error
# If the identified message is different from the expected types it will give invalid request error  
#
# + requestMessage - string type request message
# + return - Return the identity of the request message  
public isolated function fetchRequest(string requestMessage) returns 'types:RequestType {

    any|error fetchMessage = trap value:fromJsonString(requestMessage);
    if fetchMessage is any[] {
        if fetchMessage.length() === 0 {
            return invalidRequestError();
        } else {
            return fetchMessage;
        }
    }

    if fetchMessage is error {
        return parseError();
    }

    if fetchMessage is json {
        return fetchMessage;
    }

    return invalidRequestError();
}