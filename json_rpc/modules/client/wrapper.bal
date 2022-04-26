import json_rpc.util;
import json_rpc.types;
import ballerina/log;
import ballerina/websocket;

# Client wrapper
public class Client {
    private TCPClient tcpClient;
    private UDPClient udpClient;
    private WSClient wsClient;
    private ClientService clientService = new ();

    public function init(util:Config config) {
        if config is types:TCPConfig {
            self.tcpClient = new (config.host, config.port, config?.security);
            self.clientService = self.tcpClient;
        } else if config is types:UDPConfig {
            self.udpClient = new (config.host, config.port, config?.security);
            self.clientService = self.udpClient;
        } else {
            self.wsClient = new (config.host, config.port, <websocket:ClientConfiguration?>config?.security);
            self.clientService = self.wsClient;
        }
    }

    public function register() {
        if self.clientService is WSClient {
            self.wsClient = <WSClient>self.clientService;
            self.wsClient.register();
        } else if self.clientService is UDPClient {
            self.udpClient = <UDPClient>self.clientService;
            self.udpClient.register();
        } else {
            log:printWarn("TCP client works synchronusly");
        }

    }

    public function close(function () callback) {
        
        worker T {
            if self.clientService is WSClient {
                self.wsClient = <WSClient>self.clientService;
                future<boolean> futureResult = start self.wsClient.closeClient();
                boolean booleanResult = checkpanic wait futureResult;
                if booleanResult is true {
                    callback();
                }
            } else if self.clientService is UDPClient {
                self.udpClient = <UDPClient>self.clientService;
                future<boolean> futureResult = start self.udpClient.closeClient();
                boolean booleanResult = checkpanic wait futureResult;
                if booleanResult is true {
                    callback();
                }
            } else {
                self.tcpClient = <TCPClient>self.clientService;
                boolean result = self.tcpClient.closeClient();
                if result is true {
                    callback();
                }
            }
        }
    }

    public function getService(JRPCService jrpcs) returns JRPCService {
        jrpcs.clientService = self.clientService;
        return jrpcs;
    }
}
