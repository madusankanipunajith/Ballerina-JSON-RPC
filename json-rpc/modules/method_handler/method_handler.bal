import json_rpc.store;

boolean initialized = false;

public store:methMapper methMap = new();

# Description
#
# + method - User Define Method Name 
# + x - User Define Function
# + return - Return Value Is error otherwise nothing is retured  
public function addFunction(string method, function (store:InputFunc) returns any|error x) returns error?{
    
    check methMap.addMethod(method, x);
   
}