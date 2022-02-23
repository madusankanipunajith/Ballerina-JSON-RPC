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

- ```Response:``` JSON response object according to the specification
- ```Request:``` JSON request object according to the specification 
- ```Error:``` JSON error object according to the specification
- ```Notification:``` JSON notification object according to the specification
- ```JRPCTypes:``` the union of the Response, Request, Error, and Notification
- ```InputParams:``` union of JSON and anydata[]. Users can use this as the input parameter when they are defining the server methods/functions. 
- ```Method:``` isolated method/function which returns any type of data or error
- ```Methods:``` It is a record and stores the collection of Method. Users can use this type when they are mapping the service’s function with the method's name of the request message.  
- ```JRPCResponse:``` response message could be a single message or batch message or nothing. Hence it is a union of Response, Error, JsonRPCTypes?[] and nil.
- ```SingleJRPCOutput:``` the union of Response and Error
- ```BatchJRPCOutput:``` It is a batch content. Hence it is easily defined as a JsonRPCTypes?[] 
- ```BatchInput:``` It is used inside the client-side of the application. When users want to send a batch message to the server, they can use this as input. This record consists of an attribute called “notification”. According to the boolean value of the “notification” attribute, the library identifies whether the message is request type or notification type. By default, it is a request type.  
- ```TCPConfig:``` It is used to configure the TCP protocol with host and port 
- ```UDPConfig:``` It is used to configure the UDP protocol with host and port 
- ```WSConfig:``` It is used to configure the WS protocol with host and port 

**Server module:** It consists of the server-side implementation of the library and users can access the module hence it is public. Basically, this module fetches the request message which comes from the client and sends a response to the particular client. Server module functions that are available for the users are shown below.

- ```sendResponse:``` This method is used to send the response message of the fetched request message to a particular client. This method has two inputs. They are protocol’s caller(TCP caller or UDP caller or WebSocket caller) and byte message (serialized message)
Furthermore, this framework (library provides some data frames to the user for establishing the server) is having two public classes called “JRPCService” and “JRPCMethods”. Let’s discuss them further. 
- ```JRPCService <class> :``` It stands for JSON RPC service class. When the user defines a service class (like a calculator) he should extend this class(JRPCService) to the defined service class(calculator <class>). This JRPCService class consists of an instance of JRPCMethods as a public attribute. So the user must initialize the JRPCMethods instance. Furthermore, this class consists of a public inbuilt method called name. This method is used to define the service name. The user can define any name he likes. Users should create a separate class when they define the methods/functions for the defined service. Otherwise, the service's functions might conflict with the ”name” function.  Let’s see what the “JRPCMethods ”class is. 
- ```JRPCMethods <class> :``` It stands for JSON RPC methods. This class is needed when the user is going to define the methods/functions concerning the defined service. This framework provides this class as an extendable class and users should extend this class when they are defining the defined service’s method class (for an example: calculatorMethods <class>). Furthermore, this class consists of an inbuilt function called “getMethods” which is used to map the defined service’s functions. You will get more understanding while you are referring to the demo section. 
 
**Client module:** It consists of the client-side implementation of the library and users can access the module hence it is public. This module sends the request message to the server and fetches a response message which comes from the server. These are the client module functions that are available for the users.
register: This method is available only when a user creates a client using WS or UDP protocols. This method is used to fetch/accept the response messages which are coming from the server and register those inside the central store. (Since UDP and WS protocol clients are functioning asynchronously). This method is not available when the user defines the client using TCP protocol since the TCP protocol client is functioning synchronously. 
- ```sendRequest:``` This method is used to send a single request message to the server. This function consists of two inputs. They are the method's name and parameters of the message. Furthermore, this function has a callback function that returns the response message for the particular sent request message after the client fetches the response message which has come from the server. 
- ```sendNotification:``` This method is used to send a single notification message to the server. The only difference between this method and sendRequest is that the sendNotification function doesn't have a callback function to fetch the response message. 
- ```sendBatchRequest:``` This method is used to send a batch message (collection of request and notification messages) to the server. This method consists of a single input. It is an array of BatchInput. If a user wants to add a notification message to the array, he must enable the “notification” attribute as true. Furthermore, this function has a callback function that returns the response message as a batch for the particular sent batch message after the client fetches the response message which has come from the server.
- ```sendBatchNotification :``` This method is used to send a batch message (only collection of notification messages) to the server. This method consists of a single input. It is an array of BatchInput. The difference between sendBatchRequest and this method is, this method can’t have a callback function to return the response since all request messages are notifications. 
- ```closeClient:```  This method is used to disconnect the client from the server.
- ```ClientService <class>:``` This is an abstract class that resides all the service methods that are provided by the client (sendRequest, sendNotification, etc)
- ```TCPClient <class>:``` This is a public class that can be used for creating a client using the TCP protocol. Furthermore, this class is extended by the ClientService class. 
- ```UDPClient <class>:```  This is a public class that can be used for creating a client using the UDP protocol. Furthermore, this class is extended by the ClientService class. 
- ```WSClient <class>:```  This is a public class that can be used for creating a client using the WS protocol. Furthermore, this class is extended by the ClientService class. 
- ```JRPCService <class> :```  It stands for JSON RPC service class. When the user defines a service class (like a calculator) he should extend this class(JRPCService) to the defined service class(calculator). This JRPCService class consists of an instance of ClientService as a public attribute. So the user must initialize the ClientService instance. After that, the user can define reusable functions inside the implemented service class. When a user wants to define more services instead of a single service, this class will be helpful.
- ```Client <class>:``` This is the wrapper of TCP, UDP, and WS clients given by the library. The constructor of this class is a protocol’s configured data type. According to the protocol config types the user has given, a specific client will be created. Furthermore,  When a user wants to define more services instead of a single service, this class will be helpful. 
You will get more understanding about these classes given by the library when you are moving to the demo part. 
  
### High-level components of the library (client and server)

### Workflow diagrams (client and server)

 This is the high-level workflow diagram for the client and server.

 **Client**
 
 **Server**

### Implementing a client by using the library. 

We can create 3 types of clients by using this library. They are TCP client, UDP client, and WebSocket client. UDP and WebSocket clients have been implemented as asynchronous clients but TCP behaves synchronously. Here, we will show how to create a library level (lower level) client and a secondary level client (using a wrapper). 

 **Library level implementation** 
 1) Initialize a client and register it. (WebSocket protocol has been used here)
 2) Establish/define the client’s methods (send messages to the server)
 
**Important:** when the user has defined multiple services on the server-side, this method’s name should be {$service name}/method’s name (example: “calculator/add”). Furthermore, make sure that the service’s name must match with the string name which is defined inside the “name” function that resides in the user-defined service class of the server-side. 
 
 3) Close the client eventually.
 
 
 **Secondary level implementation (wrapper)** 
 1) Create a class separately and initialize a WebSocket client in it. 
 2) Define reusable functions inside the class 
 3) Define member methods for closing the client and registering the client. 

**Note:** If the user has used a protocol like UDP or WS to implement the client, all the functions are working asynchronously (methods are not waiting for the execution). This is pretty much similar to the execution inside a rest API in the node js framework.

**Note:** If the user has used a protocol like TCP to implement the client, all the functions are working synchronously (methods are waiting until the previous function is completed).    

> This is just a single way to implement a client using the library. This method is useful when the user wants to define a single service class (calculator). Now assume that if the user wants to add more service classes (calculator and thermometer) instead of a single service class, how does the user manage that?. For managing that scenario, this library will give nice wrappers to the users to enhance the usability and readability of the code.

**Process :**
 1) Create a service class and extend it from JRPCService class (given by the library)
 2) Initialize the ClientService 
 3) Add/define the reusable methods by using the initialized client service instance
 4) Create a Client instance by adding a necessary protocol configuration.
 5) Register the client
 6) Get the instance of defined service by using the getService() method. (User should cast with their service class before assigning the instance of the service class)
 7) Add the defined service’s methods (reusable methods)
 8) Close the client.
 
 Example 01: Create a single service (only calculator)
 
 Example 02: Create multiple services (calculator and thermometer)
 
### Implementing a server by using the library.
 
We can create 3 types of servers by using this library. They are TCP server, UDP server, and WebSocket server. For the demonstration, WebSocket is used as the protocol.

1) Create a service and initialize the service’s methods.
2) Create a service’s methods class and map service’s methods
Here, “add”,” sub” and “div” are the method’s names of the request message. Users must map their defined service’s functions with the method's name of the request message like  above. 
 
**Important:** let’s assume that the user has defined more services on behalf of the single service. In such scenarios, users must define their method’s name for the request message as {$service name}/method’s name (example: “calculator/add''). You will get a better understanding about that part in the future.   

3) Create a server and initialize the defined service or services (wrapper)
 
**Note:** Users can initialize their server without using this wrapper also if they want. 

Code example : 
```Ballerina
server:Server serv = new (new Calculator());
serv.sendResponse(caller, message); // should be defined inside the onBinaryMessage() method which is a remote function provided by the websocket module. 
```
 4) Call the sendResponse message

When you are using the sendResponse function it is better to define the function inside a  worker. Because by using that way, we will be able to manage concurrency. Otherwise, the server works synchronously (until the received request has proceeded, the next request is not considered to proceed). The below image represents how to define the function inside a worker as well. 

Now you have a better understanding of how to define a server, service, service’s methods, and how to work with them. But it is only a single service. Let’s see how to create multiple services (example: calculator and thermometer) on the server side and work with them.  

**Workflow :**
 1) Create multiple service classes and define their service’s name inside the “name” function after extending from the “JRPCService” class. 
 2) Create service method classes with respect to the defined services and map the initialized service’s methods inside the “getMethods” after extending from the JRPCMethods class. 

**Note:** make sure to add the request's method name as “{$service name}/method name” when you are creating the client-side. Otherwise, the server will return the methodNotFound error for the requested message. You will get a better understanding from future demos. 

  3) Initialize the server with multiple services. For that, you can add multiple service class instances into the constructor of the server as an array.   

**Demo :**
For the demonstration, we have considered two service classes called calculator and thermometer. 
 
1) defining the calculator service and its method class
2) defining the thermometer service and its method class
3) initialize the server with multiple services  
4) client side implementation

**Note:** Sometimes, you might see below type of warning messages on the terminal. It is given by the Ballerina just to alert you. Furthermore, it is not an error but just a warning. Make sure that you have avoided concurrent access to the same mutable instance or object. If you are sure that there is not a concurrency issue in your application, please ignore that warning message.

**Note:** Some examples (use cases) can be found through this GitHub link
Link : 
 

