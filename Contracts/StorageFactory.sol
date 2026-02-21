// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ThirdStorage.sol";

contract StorageFactory {

    // declare a new object of type ThirdStorage
    //ThirdStorage public thirdStorage;

    // Now make it an array
    ThirdStorage[] public thirdStorageArray;

    // function to create and deploy ThirdStorage contracts
    function createSimpleStorageContract () public {
        // assign a value to the object thirdStorage - the value being a new ThirdStorage contract - 
        // actually it seems to be the address of the ThirdStorage contract
        //thirdStorage = new ThirdStorage();

        // and for the array
        ThirdStorage thirdStorage = new ThirdStorage();
        // this creates an array of contract addresses
        thirdStorageArray.push(thirdStorage);
    }

    // function to store stuff in ThirdStorage contracts
    function sfStore (uint256 _thirdStorageIndex, uint256 _thirdStorageNumber) public {
        // to interact with any contract we need the contract address and 
        // Application Binary Interface (ABI)

        // don't strictly need all this:
        ThirdStorage thirdStorage = ThirdStorage(thirdStorageArray[_thirdStorageIndex]);
        // can just do this:
        // ThirdStorage thirdStorage = thirdStorageArray[_thirdStorageIndex];
        thirdStorage.store(_thirdStorageNumber);
    }

    // function to read back from ThirdStorage contracts
    function sfRetrieve (uint256 _thirdStorageIndex) public view returns (uint256) {
        ThirdStorage thirdStorage = thirdStorageArray[_thirdStorageIndex];
        return thirdStorage.retrieve();
    }
}