// import ballerina/io;
// import ballerina/lang.runtime;

// int[] timer = [5,2,3,4,1];
// int[] answer = [];
// public function main() {
//     test();
// }


// function test() {
    
//     foreach var item in timer {
//         execute(item);
//     }
     
//     runtime:sleep(5);    
//     io:println("finished");
//     io:println(answer);
// }

// function execute(int time){
    
//     worker A {
//         runtime:sleep(<decimal> time);
//         io:println("working - ", time);
//         answer.push(time);  
//     }
// }

// isolated function madu(){
//     lock {
        
//     }
// }

import ballerina/io;
import ballerina/log;
import ballerina/tcp;
service on new tcp:Listener(3000) {

    remote function onConnect(tcp:Caller caller)
                              returns tcp:ConnectionService {
        io:println("Client connected to echo server: ", caller.remotePort);
        return new EchoService();
    }
}

service class EchoService {
    *tcp:ConnectionService;
    
    remote function onBytes(tcp:Caller caller, readonly & byte[] data) 
        returns tcp:Error? {
        string|error fromBytes = string:fromBytes(data);

        if fromBytes is string{
            name(fromBytes);
        }
       
        return caller->writeBytes(data);
    }

    remote function onError(tcp:Error err) {
        log:printError("An error occurred", 'error = err);
    }

    remote function onClose() {
        io:println("Client left");
    }
}

function name(string name) {
    
}