// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ThirdStorage.sol";


// the following code sets up inheritance
// WeirdStorage contract inherits all the functionality of ThirdStorage
// "is" keyword means WeirdStorage is exactly the same as ThirdStorage
// we can then add new functionality in this "child" contract or modify existing functionality
contract WeirdStorage is ThirdStorage {

    // to modify exisitng functions we use the keywords "virtual" and "override"
    // virtual keyword needs to be specified in the parent contract
    // it needs to be specified after the function name and visibility
    // so if we want to modify the store function of ThirdStorage contract
    // we need to add the virtual keyword to the store function in that contract

    // then in this contract we use the override keyword, after the function name and visibility,
    // to specify that we are overrding the functionality of the function from the parent contract
    function store (uint256 _favNumber) public override {
        favNumber = _favNumber + 5;
    }
}