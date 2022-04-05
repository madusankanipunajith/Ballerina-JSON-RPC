import asus/json_rpc.server;
import asus/json_rpc.types;
import ballerina/websocket;
import ballerina/io;

type Emp record {
    readonly string name;
    int salary;
};

table<Emp> key(name) t = table [
        {name: "Damith", salary: 100},
        {name: "Kasun", salary: 200},
        {name: "Madusanka", salary: 300},
        {name: "Nadeeshaan", salary: 350},
        {name: "Dulaj", salary: 350}
    ];

service / on new websocket:Listener(3000) {
    resource function get .() returns websocket:Service|websocket:Error {
        return new WsService();
    }
}

EMPServer calculatorServer = new ();

service class WsService {
    *websocket:Service;
    remote function onBinaryMessage(websocket:Caller caller, byte[] data) returns websocket:Error? {
        io:println("\nmessage: ", string:fromBytes(data));
        
        calculatorServer.send(caller, data); // Didn't add worker since message should be processed searialized way
        
    }

    remote function onClose(websocket:Caller caller, int statusCode, string reason) {
        io:println(string `Client closed connection with ${statusCode} because of ${reason}`);
    }
}

// use case of the server
class EMPServer {

    server:Server serv;
    function init() {
        self.serv = new (new Employee());
    }

    public function send(websocket:Caller caller, byte[] message) {
        return self.serv.sendResponse(caller, message);
    }
}

class Employee {
    *server:JRPCService;

    function init() {
        EmpMethods cmethods = new ();
        self.methods = cmethods;
    }

    public isolated function name() returns string {
        return "employee";
    }

}

class EmpMethods {
    *server:JRPCMethods;

    private function increase(string name, int cash) {
        lock {
            foreach Emp emp in t {
                if emp.name === name {
                    emp.salary = emp.salary + cash;
                    break;
                }
            }
        }
    }

    function increaseSalary(types:InputParams ifs) returns error|(){
        json emp = {
            name: "",
            salary: 0
        };
        emp = check ifs.cloneWithType();
        map<json> e = <map<json>> emp;
        string name = <string> e["name"];
        int salary = <int> e["salary"];
        self.increase(name,salary);
    }

    function getSalary(types:InputParams ifs) returns error|int|string{
        json emp = {
            name: ""
        };
        emp = check ifs.cloneWithType();
        map<json> e = <map<json>> emp;
        string name = <string> e["name"];

        lock {
            Emp? employee = t[name];
            if employee is Emp {
                return employee.salary;
            }else {
                return "not found an employee with this name";
            }
        }
    }

    function resetSalary(types:InputParams ifs) {
        lock {
            foreach Emp emp in t {
                emp.salary = 0;
            }
        }
    }

    public isolated function getMethods() returns 'types:Methods {
        'types:Methods meth = {
            "increase": self.increaseSalary,
            "salary": self.getSalary,
            "reset": self.resetSalary
        };

        return meth;
    }

}
