import json_rpc.util;
import json_rpc.types;
import ballerina/log;
import ballerina/websocket;

# Client wrapper
public class Client {
    private TCPClient tcpClient;
    private UDPClient udpClient;
    private WSClient wsClient;
    private ClientService clientServie = new();

    public function init(util:Config config) {
        if config is types:TCPConfig {
            self.tcpClient = new(config.host,config.port, config?.security);
            self.clientServie = self.tcpClient;
        }else if config is types:UDPConfig {
            self.udpClient = new(config.host,config.port, config?.security);
            self.clientServie = self.udpClient;
        }else {
            self.wsClient = new(config.host,config.port, <websocket:ClientConfiguration?> config?.security);
            self.clientServie = self.wsClient;
        }
    }

    public function register() {
        if self.clientServie is WSClient {
            self.wsClient = <WSClient> self.clientServie;
            self.wsClient.register();
        }else if self.clientServie is UDPClient {
            self.udpClient = <UDPClient> self.clientServie;
            self.udpClient.register();
        }else {
            log:printWarn("TCP client works synchronusly");
        }

    }

    public function close() {
        if self.clientServie is WSClient {
            self.wsClient = <WSClient> self.clientServie;
            self.wsClient.closeClient();
        }else if self.clientServie is UDPClient {
            self.udpClient = <UDPClient> self.clientServie;
            self.udpClient.closeClient();
        }else {
            self.tcpClient = <TCPClient> self.clientServie;
            self.tcpClient.closeClient();
        }
    }

    public function getService(JRPCService jrpcs) returns JRPCService{
        jrpcs.clientService = self.clientServie;
        return jrpcs;
    }
}