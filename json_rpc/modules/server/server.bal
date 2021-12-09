import json_rpc.caller;
import json_rpc.'type;
import json_rpc.util;

type BatchResponse 'type:JsonRPCTypes?[]; 

# User Input parameters  
public type Input 'type:InputFunc|anydata[];

public class JRPCService {

    public 'type:JRPCMethods methods;

    public isolated function init() {
        self.methods = new();
    }

    public isolated function name() returns string|error{
        return "";
    }

}


public class Server {

    private JRPCService jservice;

    public isolated function init(JRPCService srv) {
        self.jservice = srv;
    }

    private isolated function methodFilter('type:Request result) returns 'type:Method|error{

            string method = result.method;            

            'type:Methods allMethods = self.jservice.methods.getMethods();

            'type:Method|error selectedMethod = trap allMethods.get(method);

            if selectedMethod is error {

                return error("method is not found...");

            }else{

                return selectedMethod;
            }
        
    }

    private isolated function executeSingleJson('type:Request message) returns 'type:Error|'type:Response?{

            'type:Method|error mf = self.methodFilter(message);

            if mf is error{
                return util:methodNotFoundError(message.id);
            }

            return checkpanic caller:executor(message, mf);

    }

    private isolated function executeBatchJson(json[] message) returns BatchResponse{
        BatchResponse batch_res_array = [];

            foreach var item in message {
                
                if caller:checker(item) is 'type:Request{
                    batch_res_array.push(self.executeSingleJson(<'type:Request> caller:checker(item)));
                }

                if caller:checker(item) is 'type:Error{
                    batch_res_array.push(caller:checker(item));
                }
                              
            }

            return batch_res_array;
        

    }

    public isolated function runner(string message) returns 'type:JsonRPCTypes|BatchResponse?{
       
        'type:Identy identity = caller:requestIdentifier(message);

        if identity is 'type:Error{
            return identity;
        }

        if identity is map<json>{
           
            if caller:checker(identity) is 'type:Request {
                return self.executeSingleJson(<'type:Request> caller:checker(identity));     
            }

            if caller:checker(identity) is 'type:Error{
                return caller:checker(identity);
            }
           
        }   

        if identity is json[]{
            return self.executeBatchJson(identity);
        }

        return util:serverError();
    }

}