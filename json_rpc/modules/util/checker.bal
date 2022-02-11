import json_rpc.'types;

# Check whether fetched message is with correct standards according to the json rpc specification
#
# + message - json message
# + return - Return valid error/request/notification  
public isolated function checkInput(json message) returns 'types:Error|'types:Request|'types:Notification|null {
    // convirt the json message into necessary jrpc data type (unmarshalling process)
    'types:JsonRPCTypes result = validate(message);

    if result is 'types:Error {
        return result;
    }

    if result is 'types:Request {
        anydata reqestParams = result.params;

        if (!(reqestParams is anydata[]) && !(reqestParams is map<anydata>) && !(reqestParams === ())) {
            return invalidMethodParams(result.id);
        }

        return result;
    }

    if result is 'types:Notification {
        anydata reqestParams = result.params;

        if (!(reqestParams is anydata[]) && !(reqestParams is map<anydata>) && !(reqestParams === ())) {
            return null;
        }

        return result;
    }

    // if it is a response or something else
    return null;
}