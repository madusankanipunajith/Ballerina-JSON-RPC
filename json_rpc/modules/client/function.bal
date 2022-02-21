import json_rpc.types;
import ballerina/lang.value;
import json_rpc.util;

// Internal function which are used inside the client module
function fetchResponse(string response) returns types:JRPCResponse {
    BatchJRPCOutput bjo = [];

    any|error fetchMessage = trap value:fromJsonString(response);

    if fetchMessage is any[] {
        if fetchMessage.length() === 0 {
            return <BatchJRPCOutput>[];
        } else {
            foreach var item in fetchMessage {
                bjo.push(util:validate(<json>item));
            }
            return bjo;
        }
    } else if fetchMessage is json {
        types:JRPCTypes result = util:validate(fetchMessage);
        types:Response|types:Error convirtedResponse = <types:Response|types:Error>result;
        return convirtedResponse;
    } else {
        return ();
    }
}

// Internal function which are used inside the client module
function createBatchRequest(types:BatchInput[] batch, Store store) returns types:JRPCTypes[] {
    types:JRPCTypes[] request = [];

    foreach types:BatchInput item in batch {
        if item.notification {
            request.push(util:sendNotification(item.method, item.params));
        } else {
            int id = store.genarateId();
            request.push(util:sendRequest(id, item.method, item.params));
        }
    }

    return request;
}

// Internal function which are used inside the client module
function createBatchNotification(types:BatchInput[] batch) returns types:JRPCTypes[] {
    types:JRPCTypes[] notification = [];
    foreach types:BatchInput item in batch {
        notification.push(util:sendNotification(item.method, item.params));
    }

    return notification;
}