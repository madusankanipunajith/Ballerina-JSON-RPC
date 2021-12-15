import json_rpc.types;


// 1st method
public class singleClientRPC {

    private boolean isRequest = false;
    private types:Request request ={
        id: 0,
        params: null,
        method: "",
        jsonrpc: "2.0"
    };
    private types:Notification notification ={
        params: null,
        method: "",
        jsonrpc: "2.0"
    };

    public function init( string method, anydata params, int? id = null){
        if id is null {

            self.notification.method = method;
            self.notification.params = params;

        }else{

            self.request.id = id;
            self.request.params = params;
            self.request.method = method;

            self.isRequest = true;

        }
    }

    public isolated function getJRPCMessage() returns types:Request|types:Notification{
        
        if self.isRequest {
            
            return self.request;
        
        }else{

            return self.notification;
        }

    }
}


public class batchClientRPC {

    private types:BatchJRPCInput[] batch_array = [];

    public function init(types:ClientInput? input){
        
        if input is null {
            
            self.batch_array = [];
        
        }else{
            
            foreach var item in input {
               
                if item.id is null{
                    
                    types:Notification notification ={
                        params: null,
                        method: "",
                        jsonrpc: "2.0"
                    };
                    
                    notification.method = item.method;
                    notification.params = item.params;

                    self.batch_array.push(notification);
                    
                } else {
                    types:Request request ={
                        id: 0,
                        params: null,
                        method: "",
                        jsonrpc: "2.0"
                    };
                    request.id = <int> item.id;
                    request.method = item.method;
                    request.params = item.params;

                    self.batch_array.push(request);
                }
            }
        }
    }

    public function getJRPCMessage() returns 'types:BatchJRPCInput[]{
        
        return self.batch_array;
    }
}


// 2nd method
public class ClientMethods {

    private types:Request request ={
        id: 0,
        params: null,
        method: "",
        jsonrpc: "2.0"
    };
    private types:Notification notification ={
        params: null,
        method: "",
        jsonrpc: "2.0"
    };
    private types:BatchJRPCInput[] batch_array = [];

    
    public function createRequest(string method, anydata params,int id) returns types:Request{
            
        self.request.id = id;
        self.request.params = params;
        self.request.method = method;

        return self.request;
    }

    public function createNotification(string method, anydata params) returns types:Notification{
        
        self.notification.method = method;
        self.notification.params = params;

        return self.notification;
    }

    public function createBatch(types:ClientInput? input) returns types:BatchJRPCInput[]{
        
        if input is null {
            
            self.batch_array = [];
        
        }else{
            
            foreach var item in input {
               
                if item.id is null{
                    
                    types:Notification notification ={
                        params: null,
                        method: "",
                        jsonrpc: "2.0"
                    };
                    
                    notification.method = item.method;
                    notification.params = item.params;

                    self.batch_array.push(notification);
                    
                }else{
                    types:Request request ={
                        id: 0,
                        params: null,
                        method: "",
                        jsonrpc: "2.0"
                    };
                    request.id = <int> item.id;
                    request.method = item.method;
                    request.params = item.params;

                    self.batch_array.push(request);
                }
            }
        }
        
        return self.batch_array;
    }
}