import ballerina/io;

type JsonRecord record {|
    int id?;
    string method?;
    string result?;
    anydata params?;
    string jsonrpc;
    json err?;
|};

public function paramFilter(string msg) returns anydata|error{
    io:StringReader sr = new(msg, encoding = "UTF-8");
    json message =  check sr.readJson();

    JsonRecord jr = check message.cloneWithType();

    if jr?.params is json{
        return jr?.params;
    }

    if jr?.params is anydata[]{
        return jr?.params;
    }
}

public function idFilter(string msg) returns int?|error{
    io:StringReader sr = new(msg, encoding = "UTF-8");
    json message =  check sr.readJson();

    JsonRecord jr = check message.cloneWithType();

    int? id = jr?.id is null ? null : jr?.id;
    return id;
}

public function methodFilter(string msg) returns string?|error{
    io:StringReader sr = new(msg, encoding = "UTF-8");
    json message =  check sr.readJson();

    JsonRecord jr = check message.cloneWithType();

    string? method = jr?.method is null ? null : jr?.method;

    return method;
}

