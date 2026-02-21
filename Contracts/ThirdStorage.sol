// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

contract ThirdStorage {

    // VARIABLES

    // example variables
    bool hasFavNumber = true;           // boolean can be true or false
    uint favouriteNumber = 13;          // unsigned integers can only be +ve
    int256 faveNegNumber = -13;         // specify no. of bits from 8-256
    string textFavNumber = "thirteen";  // string is actually a bytes object, but only for text
    address myAddress = 0xd9145CCE52D386f254917e481eB44e9943F39138;
    bytes32 favBytes = "numberThirteen";

    // variable for use in later code
    // public keyword makes this visible/usable/accessible outside the contract, 
    // without specifying pyblic keyword (ie. uint256 favNumber;) the variable will 
    // by default be "internal"
    uint256 public favNumber;

    struct People {
        string name;
        uint256 favNumber;
    }
    
    //People public person = People({favNumber: 13, name: "Me"})

    // people array
    People[] public people;

    // mapping is kind of like a python dictionary
    mapping (string => uint256) public nameToFavNumber;


    // FUNCTIONS

    // this function stores a value in the global variable favNumber
    // virtual keyword added to make the function overridable by WeirdStorage contract
    // see WeirdStorage contract for more notes on this
    function store (uint256 _favNumber) public virtual {
        favNumber = _favNumber;
    }

    // this function retrieves the value stored in the global variable favNumber
    // it can access the value stored in the variable favNumber because the variable is global
    function retrieve () public view returns (uint256) {
        return favNumber;
    }

    function addPerson (string memory _name, uint256 _favNumber) public {
        people.push(People(_name, _favNumber));
        // accesses the dictionary, associates the value _favNumber with the key _name
        nameToFavNumber[_name] = _favNumber;
    }

}