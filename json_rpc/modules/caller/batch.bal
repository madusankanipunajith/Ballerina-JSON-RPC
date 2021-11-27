import ballerina/lang.value;

# Description
#
# + requestMessage - Parameter Description
# + return - Return Value Description  
public isolated function batchChecker(string requestMessage) returns int{
    any|error z = trap value:fromJsonString(requestMessage);

    if z is any[]{

        if z.length() === 0{
            return 0;
        }else{
            return 1;
        }
       
    }

    if z is error{
        return 2;
    }

    if z is json{
        return 3;
    }

    return 0;
}