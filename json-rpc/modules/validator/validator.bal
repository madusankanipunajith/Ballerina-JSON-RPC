import ballerina/lang.value;

public type JsonRecord record {|
    int id?;
    string method?;
    string result?;
    anydata params?;
    string jsonrpc;
    json err?;
|};

public type Response record {|
    int id;
    any result;
    string jsonrpc;
|};

public type Error record {|
    int? id;
    json err;
    string jsonrpc;
|};

public type Request record {
    int id;
    string method;
    anydata params;
    string jsonrpc;
};

public type Notification record {
    string method;
    anydata params;
    string jsonrpc;
};


public type JsonRPCTypes Request|Response|Error|Notification;


// 0 -> notification
// 1 -> request message
// 2 -> response message
// 3 -> invalid message

public function messageValidator(string jsonString) returns JsonRPCTypes|error{
    
    json message = check value:fromJsonString(jsonString);
    
    JsonRecord|error jmessage = message.cloneWithType();
     

    // io:println(typeof message.params);
    // io:println(jmessage);
    

    if jmessage is error{
        //return error("something went wrong in message conversion");
        json|error? errId = message.id;
        int? eid; 

        if errId is json{
            eid = <int?> errId;
        }else{
            eid = null;
        }

        Error err = {
            id:  eid,
            err: {code:"-32600", message: "something went wrong in message conversion or Invalid request"},
            jsonrpc: "2.0"
        };

        return err;
    }
    else{
        if jmessage?.id === () && !(jmessage?.method is null) && !(jmessage?.params is null){
            
            Notification r = {
                method: <string> jmessage?.method,
                params: jmessage?.params,
                jsonrpc: "2.0"
            };

            return r;
        }

        if jmessage?.method is null && jmessage?.params is null && jmessage?.err is null && !(jmessage?.id === ()){
            Response r ={
                id: <int> jmessage?.id,
                result: <string> jmessage?.result,
                jsonrpc: "2.0"
            };

            return r;
        }

        if !(jmessage?.err is null) {
            Error r ={
                id: jmessage?.id is null ? null : <int> jmessage?.id,
                err: jmessage?.err,
                jsonrpc: "2.0"
            };

            return r;
        }

        // request message can have params but not compalsory
        if jmessage?.id !== () && !(jmessage?.method is null){
            Request r ={
                id: <int> jmessage?.id,
                params: jmessage?.params is null? null : jmessage?.params,
                method: <string> jmessage?.method,
                jsonrpc: "2.0"
            };

            return r;
        }

        //return error("cannot find a json rpc message type");
        Error err={
            id: jmessage?.id is null ? null : <int> jmessage?.id,
            err: {code:"-32600", message:"cannot find a json rpc message type (Invalid JSON object was recieved by the server)"},
            jsonrpc: "2.0"
        };

        return err;
    }
}
