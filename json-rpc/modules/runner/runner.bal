import ballerina/lang.value;
import json_rpc.validator;
import json_rpc.caller;
import ballerina/io;

public type BatchResponse validator:JsonRPCTypes[];
BatchResponse batch_res_array = [];

public function executor(string argument) returns validator:Error|validator:Response|BatchResponse|error?{
    
    any|error z = trap value:fromJsonString(argument);
    io:println(typeof z);

    if z is any[]{
        //io:println("This is an array");
        if z.length() === 0{
            validator:Error err ={
                id: null,
                err:{"code": "-32600", "message": "Invalid request"},
                jsonrpc: "2.0"
            };

            return err;
        }else{
            foreach var item in z {
                validator:JsonRPCTypes? response = check caller:caller(item.toString());

                if response is validator:Response || response is validator:Error{
                    batch_res_array.push(response);
                }
            }

            return batch_res_array;
        }

    }else if z is error {
        //io:println("error is occured...");
        validator:Error err ={
            id: null,
            err:{"code": "-32700", "message": "Parse error"},
            jsonrpc: "2.0"
        };

        return err;
    }
    else if z is json{
        //io:println("This is a json string");
        // caller function return a panic error if and only if the error is only beign in the user define function
        validator:JsonRPCTypes? response = check caller:caller(argument);

        if response is validator:Error || response is validator:Response{
            return response;
        }

    }else{

        validator:Error err ={
            id: null,
            err:{"code": "-32000", "message": "Server error"},
            jsonrpc: "2.0"
        };

        return err;
    }

    // swanlake beta4 support
    return;
}
