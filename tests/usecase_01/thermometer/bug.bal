import ballerina/io;

public type InputFunc json|anydata[];

type Nip record {|
    int x;
    int y;
|};

public function main() {
    name({"x":10, "y":20});
    name2({"x":100, "y":200});

}

function name(InputFunc ifs) {
    
    map<json> message ={
        x:0,
        y:0
    };

    message = <map<json>> ifs;
    int answer = <int> message.get("x") + <int> message.get("y");
    io:println(answer);
}

function name2(InputFunc ifs) {
    Nip nip = checkpanic ifs.cloneWithType();
    int answer = nip.x + nip.y;
    io:println(answer);
}

function name3(InputFunc ifs) {
    
}
