// SPDX-License-Identifier: MIT
pragma solidity 0.8.8;

contract NewStorage {
    
    // Variables

    //uint256 public favNumber;
    uint256 favNumber;

    struct People {
        uint256 favNumber;
        string name;
    }

    //People public person = People({favNumber: 13, name: "Me"});

    //unit256[] public favNumbersList;
    People[] public people;

    mapping(string => uint256) public nameToFavNumber;


    // Functions

    function store (uint256 _favNumber) public {
        favNumber = _favNumber;
    }

    function retrieve () public view returns (uint256) {
        return favNumber;
    }

    function addPerson (uint256 _favNumber, string memory _name) public {
        people.push(People(_favNumber, _name));
        nameToFavNumber[_name] = _favNumber;
    }
}