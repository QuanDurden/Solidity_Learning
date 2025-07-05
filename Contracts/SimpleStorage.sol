// SPDX-License-Identifier: MIT
pragma solidity 0.8.8;

// Contracts in solidity like classes in Python/C++/etc.
contract SimpleStorage{
    // Basic data types include boolean, uint, int, address, string, bytes
    // Address type stores addresses of some sort in hex format

    // eg. bool hasFavouriteNumber = true;
    // eg. uint8 favouriteNumber = 5; - 8 bits = 1 byte, uint is unsigned ie. always +ve
    // eg. uint256 favouriteNumber = 5; - 8 bit increments up to max 256 bits
    // eg. int256 favouriteNumber = -5;
    // eg. string textFavNumber = "Five";
    // eg. bytes32 favBytes = "cat"; - 32 bytes is max size for bytes object


    // VARIABLES

    // The uint below is initialised to 0
    //uint256 public favNumber; // public keyword makes this visible/usable outside the contract
    uint256 favNumber;

    // Creates a new variable of mapping type called nameToFavNumber
    // (string => uint256) defines what the mapping does - maps a string to a number, in this case name to fav number
    // when a mapping is created everything is initailised to null value
    mapping(string => uint256) public nameToFavNumber;

    // creating a structure effectively creates a new data type, in this case called People
    struct People {
        uint256 favNumber;
        string name;
    }

    // We can now declare new variables to be of type 'People'
    //People public person = People({favNumber: 13, name: "Me"});

    // Create an array to store a list of different people
    // this array is of 'People' data type
    // square brackets after the type declaration indicate that this is an array
    // the brackets can be empty, indicating this array can be of any size
    // or a number in the brackets specifies how large the array should be, eg. [3] creates an array with 3 elements
    // this array varaible is public and its name is people
    People[] public people;


    // FUNCTIONS

    // this function modifies the state of the blockchain - so is a transaction - so costs currency
    function store(uint256 _favNumber) public {
        favNumber = _favNumber;
    }

    // view keyword means this function only reads the state from the contract
    // eg. it reads whatever is stored in favNumber but can not change/modify or update the blockchain
    function retrieve () public view returns(uint256){
        return favNumber;
    }

    // pure keyword does not allow modification of the state OR readingfrom the state
    // so what is it for?
    // eg. some mathematicla operation you need to re-use regularly
    //eg.
    //function add() public pure returns (uint256){
    //    return (1 + 1);
    //}

    // pure and view keywords do not spend any currency as they do not modify the state of the blockchain
    // currency is only spent when making a transaction - transactions modify the state of the blockchain

    // Data location must be memory or calldata for parameter in function
    // calldata, memory, storage
    // storage variables exist outside the executing function - permanent variables that can be modified.
    // calldata and memory keywords mean that the variable (is a function parameter a variable?) will only exist temporarily.
    // In this case the variable _name is only needed when being used by the function during the transaction the function defines
    // and is not needed any more after the function has finished running.
    // calldata could be used if there was no possible need to modify the variable _name
    // calldata is for temp variables that can not be modified
    // memory is for temp variables that can be modified

    // Data location can only be (and, seemingly, must be) specified for array, struct or mapping data types
    // a string is actually an array of bytes, therefore data location must be specified for variables of string type
    // This is not necessary (or possible) for unit256 type
    function addPerson (string memory _name, uint256 _favNumber) public {
        people.push(People(_favNumber, _name));
        // here we use the mapping variable nameToFavNumber
        nameToFavNumber[_name] = _favNumber;
    }
}

// eg. address = 0xd9145CCE52D386f254917e481eB44e9943F39138;