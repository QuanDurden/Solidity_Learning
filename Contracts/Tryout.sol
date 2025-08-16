// SPDX-License-Identifier: MIT
// compiler version must be greater than or equal to 0.8.26 and less than 0.9.0
pragma solidity ^0.8.26;

contract HelloWorld {

    // string public greet = "Hello World!";

    string public greet;

    // Requires an initial greeting to be entered before the contract can be deployed
    constructor(string memory _initialGreet) {
        greet = _initialGreet;
    }

    // Emables the initial greeting to be modified
    function updateGreet(string memory _newGreet) public {
        greet = _newGreet;
    }
}