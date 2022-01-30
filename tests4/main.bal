// import ballerina/time;
// import ballerina/io;
// public function main() {
//     time:Utc currentUtc = time:utcNow();
//     int starts = currentUtc[0];
//     int end = starts + 3;

//     while (starts < end) {
//         starts = time:utcNow()[0];
//         io:println(`Number of seconds from the epoch: ${currentUtc[0]}s`);
//     }
    
// }

// public function main() {
//     finc_1();
//     finc_2();
// }

// function finc_1() {
//     worker A {
//         while true {
//             io:println("A");
//         }
//     }
// }

// function finc_2() {
//     worker B {
//         while true {
//             io:println("B");
//         }
//     }
// }


