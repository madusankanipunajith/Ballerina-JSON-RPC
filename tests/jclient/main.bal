import asus/json_rpc.'types;
import asus/json_rpc.'client;
import ballerina/io;
public function main() returns error? {

    // draft

    // 'client:Client cl1 = new("localhost", 9000, 'client:TCP, clm);
    //   cl1.ops().addFunction(125, {"x":10, "y":20}, function (types:JRPCResponse t) returns () {
    //   io:println(t);   
    // });


    'client:Client cl = new();
    'client:ClientServices tcpService = check cl.setConfig("localhost", 9000, 'client:TCP);

    ClientMethods clm = new(tcpService);

    clm.addFunction(125, {"x":10, "y":20}, function (types:JRPCResponse t) returns () {
     io:println(t);   
    });

    tcpService.closeClient();

}


class ClientMethods {
  *'client:JRPCClientMethods;

  function init('client:ClientServices cls) {
    self.clientServices = cls;
  }

  public function addFunction(int id,json params, function ('types:JRPCResponse response) callback) {
    'types:Request r ={
      id:id,
      params: params,
      method:"add"
    };

    types:JRPCResponse sendMessage = self.clientServices.sendMessage(r);
    callback(sendMessage);
  }

  public function subFunction(int id,json params, function ('types:JRPCResponse response) callback) {
    'types:Request r ={
      id:id,
      params: params,
      method:"sub"
    };

    types:JRPCResponse sendMessage = self.clientServices.sendMessage(r);
    callback(sendMessage);
  }

  public function notFunction(json params) {
    'types:Notification n ={
      params: params,
      method: "mult"
    };

    self.clientServices.sendNotification(n);
  }
}