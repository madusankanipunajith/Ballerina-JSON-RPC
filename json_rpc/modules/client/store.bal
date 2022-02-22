import json_rpc.types;
import json_rpc.util;
import ballerina/time;
import ballerina/log;

# This private class is used to manage central store
class Store {
    int id = 0;
    types:Request[] requestStore = [];
    SingleJRPCOutput[] responseStore = [];
    BatchJRPCOutput[] responseBatchStore = [];

    public function genarateId() returns int {
        self.id = self.id + 1;
        return self.id;
    }

    public function getResponseStore() returns types:SingleJRPCOutput[] {
        lock {
            return self.responseStore;
        }
    }

    public function getRequestStore() returns types:Request[] {
        lock {
            return self.requestStore;
        }
    }

    public function getBatchStore() returns BatchJRPCOutput[] {
        lock {
            return self.responseBatchStore;
        }
    }

    public function pushResponse(types:SingleJRPCOutput response) {
        lock {
            self.responseStore.push(response);
        }
    }

    public function pushBatch(BatchJRPCOutput response) {
        lock {
            self.responseBatchStore.push(response);
        }
    }

    public function pushRequest(types:Request request) {
        lock {
            self.requestStore.push(request);
        }
    }

    public function findResponse(int id) returns types:Response|types:Error? {
        time:Utc currentUtc = time:utcNow();
        int strats = currentUtc[0];
        int end = strats + 10;
        while (strats < end) {
            strats = time:utcNow()[0];
            util:nap();
            lock {
                SingleJRPCOutput[] responseStore = self.getResponseStore();
                foreach types:Response|types:Error item in responseStore {
                    if item.id === id {
                        return item;
                    }
                }
            }
        }

        log:printError(NOT_RECIEVED, 'error = error(self.removeRequest(id).toString()));
        return ();
    }

    public function findBatch(int[] id) returns BatchJRPCOutput|types:Error? {
        time:Utc currentUtc = time:utcNow();
        int strats = currentUtc[0];
        int end = strats + 10;
        while (strats < end) {
            strats = time:utcNow()[0];
            util:nap();
            lock {
                BatchJRPCOutput[] batchStore = self.getBatchStore();
                foreach BatchJRPCOutput item in batchStore {
                    foreach int i in id {
                        foreach types:JRPCTypes? j in item {
                            if j is types:Response || j is types:Error {
                                if j.id === i {
                                    return item;
                                }
                            }
                        }
                    }
                }
            }
        }

        if id.length() > 0 {
            foreach int i in id {
                log:printError(NOT_RECIEVED, 'error = error(self.removeRequest(i).toString()));
            }
        } else {
            log:printError(NOT_RECIEVED, 'error = error(EMPTY_MESSAGE));
        }
        
        return ();
    }

    public function removeRequest(int|int[] id) returns types:Request|() {
        int index = 0;
        if id is int[] {
            foreach int item in id {
                lock {
                    foreach int i in 0 ..< self.requestStore.length() {
                        if self.requestStore[i].id === item {
                            index = i;
                            _ = self.requestStore.remove(index);
                        }
                    }
                }
            }
            return ();
        } else {
            lock {
                foreach int i in 0 ..< self.requestStore.length() {
                    if self.requestStore[i].id === id {
                        index = i;
                    }
                }

                return self.requestStore.remove(index);
            }
        }
    }

    public function removeResponse(int|int[] id) {
        int index = 0;
        if id is int[] {
            foreach int i in id {
                lock {
                    foreach int ind in 0 ..< self.responseBatchStore.length() {
                        BatchJRPCOutput batchJRPCOutput = self.responseBatchStore[ind];
                        foreach var item in batchJRPCOutput {
                            if item is types:Response || item is types:Error {
                                if item.id === i {
                                    index = ind;
                                    _ = self.responseBatchStore.remove(index);
                                    return;
                                }
                            }
                        }
                    }
                }
            }
        } else {
            lock {
                foreach int i in 0 ..< self.responseStore.length() {
                    if self.responseStore[i].id === id {
                        index = i;
                        break;
                    }
                }
                _ = self.responseStore.remove(index);
            }
        }
    }
}