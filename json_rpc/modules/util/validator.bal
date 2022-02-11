import json_rpc.'types;

# This method is used to convirt the fetched single message into necessary json rpc data type 
#
# + message - Fetched single json message
# + return - Return json rpc Request/Response/Error/Notification  
public isolated function validate(json message) returns 'types:JsonRPCTypes {
    'types:JsonRecord|error jmessage = trap message.cloneWithType();

    if jmessage is error {
        
        json|error? errId = message.id;
        int? eid;

        if errId is json {
            eid = <int?>errId;
        } else {
            eid = null;
        }

        return sendError(eid, {code: "-32600", message: "something went wrong in message conversion or Invalid request"});
    } else {
        
        // notification message can have params but not compalsory
        if jmessage?.id === () && !(jmessage?.method is null) {
            return sendNotification(<string>jmessage?.method, jmessage?.params);
        }

        if jmessage?.method is null && jmessage?.params is null && jmessage?.err is null && !(jmessage?.id === ()) {
            return sendResponse(<int>jmessage?.id, jmessage?.result);
        }

        // error message can have an unique id but not compalsory
        if !(jmessage?.err is null) {
            return sendError(jmessage?.id is null ? null : <int>jmessage?.id, jmessage?.err);
        }

        // request message can have params but not compalsory
        if jmessage?.id !== () && !(jmessage?.method is null) {
            return sendRequest(<int>jmessage?.id, <string>jmessage?.method, jmessage?.params is null ? null : jmessage?.params);
        }

        //return error("cannot find a json rpc message type");
        return sendError(jmessage?.id is null ? null : <int>jmessage?.id, {code: "-32600", message: "cannot find a json rpc message type (Invalid JSON object was recieved by the server)"});
    }
}