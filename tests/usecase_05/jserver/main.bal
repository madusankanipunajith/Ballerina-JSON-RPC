import ballerina/udp;
import ballerina/io;
import madusanka/json_rpc.server;
import madusanka/json_rpc.types;

type Employee record {
    string firstName;
    string lastName;
    decimal salary;
};

type Person record{
    string first;
    string last;
};

Employee[] employees = [
        {firstName: "Jones", lastName: "Welsh", salary: 1000.00},
        {firstName: "Anne", lastName: "Frank", salary: 5000.00},
        {firstName: "Rocky", lastName: "Irving", salary: 6000.00},
        {firstName: "Anne", lastName: "Perera", salary: 3000.00},
        {firstName: "Jermaine", lastName: "Perera", salary: 4000.00},
        {firstName: "Miya", lastName: "Bauer", salary: 9000.00},
        {firstName: "Rocky", lastName: "Puckett", salary: 6000.00},
        {firstName: "Jermaine", lastName: "Kent", salary: 4000.00}
    ];

service on new udp:Listener(3000) {

    remote function onDatagram(udp:Caller caller, readonly & udp:Datagram datagram) returns udp:Error? {
        io:println("Received by listener: ", string:fromBytes(datagram.data));
        svr.sendResponse(caller,datagram.data);
    }

    remote function onError(udp:Error err) {
        io:println(err);
    }
}

server:Server svr = new(new Employ());

class Employ {
    *server:JRPCService;

    function init() {
        self.methods = new EmpMethod();  
    }

    public isolated function name() returns string {
        return "employ";
    }
}

class EmpMethod{
    *server:JRPCMethods;

    public function getAllFirstNames(types:InputParams params) returns string[] {
        string[] names = from var {firstName} in employees let int len1 = firstName.length()
                        where len1 > 0 
                        let string name = firstName
                        select name;

        return names;                
    }

    public function getTotalSalary(types:InputParams params) returns int{
        decimal[] sal = from var {salary} in employees select salary;
        decimal total = 0.0;
        foreach var item in sal {
            total += item;
        }

        return <int>total;
    }

    public function getSalary(types:InputParams params) returns decimal[]|error {
        Person person = check params.cloneWithType();
        decimal[] sal = from var {firstName, lastName, salary} in employees 
                    where firstName == person.first && lastName == person.last select salary;  

        return sal;             
    }

    public function getTeamLead(types:InputParams params) returns string {
        string lead = from var e in employees
                    order by e.salary descending
                    limit 1
                    let string name = e.firstName +" "+e.lastName
                    select name;
        
        return lead;
    }

    public isolated function getMethods() returns types:Methods {
        return {
            "list_fnames":self.getAllFirstNames,
            "salary":self.getSalary,
            "lead":self.getTeamLead,
            "total":self.getTotalSalary
        };
    }
}