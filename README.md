# JSON-RPC library and a client-server framework from Ballerina

### Abstract 
JSON-RPC is a stateless, lightweight remote procedure call (RPC) protocol. Primarily, the specification defines several data structures and the rules around their processing. It is transport agnostic in that the concepts can be used within the same process, over sockets, over HTTP, or in many various message passing environments. It uses JSON (RFC 4627) as the data format.

### Usage
By using this library, ballerina developers can easily manipulate JSON-RPC messages between client and server. Furthermore, they can easily use inbuilt functions in the library and due to the framework, all the developers can implement some unique client-server architecture (earlier according to the developer, implementations can be different from one to one). In addition to that, we can avoid repetition and improve reusability as well. 
Furthermore, developers don’t have to worry about the request and response message parsing between client and server. Because that part is handled by the library that we are going to implement.

### Design of the implementation 

This library has been implemented according to the JSON RPC (2.0) specification.
Link to the specification:  https://www.jsonrpc.org/specification




