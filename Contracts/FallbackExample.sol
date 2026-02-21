// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

contract FallbackExample {
    uint256 public result;

    receive () external payable {
        // We don't use the function keyword when declaring/defining receive functions - 
        // the compiler knows that receive() is a sepcial function
        // it is called whenever a transaction is sent to this contract, even if the value 
        // sent is 0, and there is no calldata specifying a function to call, an address etc.
        result = 1;
    }

    fallback() external payable {
        // Similarly no function keyword with fallback function
        // it is called when a transaction is sent and there is some calldata but that calldata
        // does not specify a function etc.
        result = 2;
    }
}