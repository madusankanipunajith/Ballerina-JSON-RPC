public type nipFunc function (string x) returns anydata|error;


public type InputFunc record {|
    
    anydata...;

|};

public type MethRecord record {|
    string name;
    int id;
    nipFunc cf;
|}[];

public MethRecord method_array = [];

// method mapper initialization
public map<function (InputFunc func) returns any|error> methodMapper = {};

public class methMapper {
    private map<function (InputFunc func) returns any|error> methodMapper = {};

    public function addMethod(string method, function (InputFunc) returns any|error func) returns error?{

        if (self.methodMapper[method] is null) {
     
            self.methodMapper[method] =  func.clone();     
    
        }else{
            return error("same request method name cannot be applied...");
        }
    
    }

    public function getMethod(string method) returns function (InputFunc) returns any|error{
        return self.methodMapper.get(method);
    }

    public function findMethod(string method) returns boolean{
        
        if (self.methodMapper[method] is null){
            return true;
        }else {
            return false;
        }
    }
}
