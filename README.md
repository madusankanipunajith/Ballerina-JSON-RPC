# JSON-RPC library and a client-server framework from Ballerina

### Abstract 
JSON-RPC is a stateless, lightweight remote procedure call (RPC) protocol. Primarily, the specification defines several data structures and the rules around their processing. It is transport agnostic in that the concepts can be used within the same process, over sockets, over HTTP, or in many various message passing environments. It uses JSON (RFC 4627) as the data format.

### Usage
By using this library, ballerina developers can easily manipulate JSON-RPC messages between client and server. Furthermore, they can easily use inbuilt functions in the library and due to the framework, all the developers can implement some unique client-server architecture (earlier according to the developer, implementations can be different from one to one). In addition to that, we can avoid repetition and improve reusability as well. 
Furthermore, developers don’t have to worry about the request and response message parsing between client and server. Because that part is handled by the library that we are going to implement.

### Design of the implementation 

This library has been implemented according to the JSON RPC (2.0) specification.
Link to the specification:  https://www.jsonrpc.org/specification

![table](https://user-images.githubusercontent.com/56679833/155166649-000db5a7-7a35-47d9-9249-12d98bf7abb4.PNG)


### Implemented modules of the library package

- Util module (private) 
- Types module (public) 
- Client module (public) 
- Server module (public)

**Util module:** It consists of all the utility functions which can be used in both client and server modules. Furthermore, we can define this module as a hidden layer and all the validation process is run inside this module. Hence, this is a private module and users can’t access this module.

**Types module:** It consists of all the public data types of the library. This module has been used in all other modules and it is a public module. Therefore, users can access this library. Below shows the data types in the “types” module which are available for the users.

- **Response:** JSON response object according to the specification
- **Request:** JSON request object according to the specification 
- **Error:** JSON error object according to the specification
- **Notification:** JSON notification object according to the specification
- **JRPCTypes:** the union of the Response, Request, Error, and Notification
- **InputParams:** union of JSON and anydata[]. Users can use this as the input parameter when they are defining the server methods/functions. 
- **Method:** isolated method/function which returns any type of data or error
- **Methods:** It is a record and stores the collection of Method. Users can use this type when they are mapping the service’s function with the method's name of the request message.  
- **JRPCResponse:** response message could be a single message or batch message or nothing. Hence it is a union of Response, Error, JsonRPCTypes?[] and nil.
- **SingleJRPCOutput:** the union of Response and Error
- **BatchJRPCOutput:** It is a batch content. Hence it is easily defined as a JsonRPCTypes?[] 
- **BatchInput:** It is used inside the client-side of the application. When users want to send a batch message to the server, they can use this as input. This record consists of an attribute called “notification”. According to the boolean value of the “notification” attribute, the library identifies whether the message is request type or notification type. By default, it is a request type.  
- **TCPConfig:** It is used to configure the TCP protocol with host and port 
- **UDPConfig:** It is used to configure the UDP protocol with host and port 
- **WSConfig:** It is used to configure the WS protocol with host and port 

**Server module:** It consists of the server-side implementation of the library and users can access the module hence it is public. Basically, this module fetches the request message which comes from the client and sends a response to the particular client. Server module functions that are available for the users are shown below.

- **sendResponse:** This method is used to send the response message of the fetched request message to a particular client. This method has two inputs. They are protocol’s caller(TCP caller or UDP caller or WebSocket caller) and byte message (serialized message)
Furthermore, this framework (library provides some data frames to the user for establishing the server) is having two public classes called “JRPCService” and “JRPCMethods”. Let’s discuss them further. 
- **JRPCService <class> :** It stands for JSON RPC service class. When the user defines a service class (like a calculator) he should extend this class(JRPCService) to the defined service class(calculator <class>). This JRPCService class consists of an instance of JRPCMethods as a public attribute. So the user must initialize the JRPCMethods instance. Furthermore, this class consists of a public inbuilt method called name. This method is used to define the service name. The user can define any name he likes. Users should create a separate class when they define the methods/functions for the defined service. Otherwise, the service's functions might conflict with the ”name” function.  Let’s see what the “JRPCMethods ”class is. 
- **JRPCMethods <class> :** It stands for JSON RPC methods. This class is needed when the user is going to define the methods/functions concerning the defined service. This framework provides this class as an extendable class and users should extend this class when they are defining the defined service’s method class (for an example: calculatorMethods <class>). Furthermore, this class consists of an inbuilt function called “getMethods” which is used to map the defined service’s functions. You will get more understanding while you are referring to the demo section. 
 
**Client module:** It consists of the client-side implementation of the library and users can access the module hence it is public. This module sends the request message to the server and fetches a response message which comes from the server. These are the client module functions that are available for the users.
register: This method is available only when a user creates a client using WS or UDP protocols. This method is used to fetch/accept the response messages which are coming from the server and register those inside the central store. (Since UDP and WS protocol clients are functioning asynchronously). This method is not available when the user defines the client using TCP protocol since the TCP protocol client is functioning synchronously. 
- **sendRequest:** This method is used to send a single request message to the server. This function consists of two inputs. They are the method's name and parameters of the message. Furthermore, this function has a callback function that returns the response message for the particular sent request message after the client fetches the response message which has come from the server. 
- **sendNotification:** This method is used to send a single notification message to the server. The only difference between this method and sendRequest is that the sendNotification function doesn't have a callback function to fetch the response message. 
- **sendBatchRequest:** This method is used to send a batch message (collection of request and notification messages) to the server. This method consists of a single input. It is an array of BatchInput. If a user wants to add a notification message to the array, he must enable the “notification” attribute as true. Furthermore, this function has a callback function that returns the response message as a batch for the particular sent batch message after the client fetches the response message which has come from the server.
- **sendBatchNotification :** This method is used to send a batch message (only collection of notification messages) to the server. This method consists of a single input. It is an array of BatchInput. The difference between sendBatchRequest and this method is, this method can’t have a callback function to return the response since all request messages are notifications. 
- **closeClient:**  This method is used to disconnect the client from the server.
- **ClientService <class>:** This is an abstract class that resides all the service methods that are provided by the client (sendRequest, sendNotification, etc)
- **TCPClient <class>:** This is a public class that can be used for creating a client using the TCP protocol. Furthermore, this class is extended by the ClientService class. 
- **UDPClient <class>:**  This is a public class that can be used for creating a client using the UDP protocol. Furthermore, this class is extended by the ClientService class. 
- **WSClient <class>:**  This is a public class that can be used for creating a client using the WS protocol. Furthermore, this class is extended by the ClientService class. 
- **JRPCService <class> :**  It stands for JSON RPC service class. When the user defines a service class (like a calculator) he should extend this class(JRPCService) to the defined service class(calculator). This JRPCService class consists of an instance of ClientService as a public attribute. So the user must initialize the ClientService instance. After that, the user can define reusable functions inside the implemented service class. When a user wants to define more services instead of a single service, this class will be helpful.
- **Client <class>:** This is the wrapper of TCP, UDP, and WS clients given by the library. The constructor of this class is a protocol’s configured data type. According to the protocol config types the user has given, a specific client will be created. Furthermore,  When a user wants to define more services instead of a single service, this class will be helpful. 
You will get more understanding about these classes given by the library when you are moving to the demo part. 
  
  



