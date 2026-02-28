// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "./PriceConverter.sol";

// Creating custom error is done outside the contract
error NotOwner();

contract FundMe {

    // In order to be able to actually use any of the functions in the PriceConverter
    // library, we have to do this:
    using PriceConverter for uint256;
    // apparently makes the functions in the library into functions that can be called
    // on uint256s

    // Minimum amount of USD that can be sent to the contract
    // Using constant keyword saves gas - can use it here at the value of minimumUSD is
    // never changed - constant
    // Naming convention for constants - all capitals
    uint256 constant MINIMUM_USD = 50 * 1e18;

    // Create an array to store addresses of funders
    address[] public funders;

    // Create an address variable to store the address of the contract owner
    // Variables whose value is never changed but is set outside the line they are declared in
    // eg. in the constructor, can be declared immutable
    address public immutable i_owner; // i_ naming convention for immutable variables

    // Create a mapping to store the amount of ETH sent by each funder
    mapping(address => uint256) public addressToAmountFunded;


    // Constructor function
    constructor() {
        // constructor function is called immediately on deployment of the contract
        // so when the contract is deployed msg.sender is the person who deployed it and
        // setting owner = msg.sender ensures that the person who deploys the contract is the owner
        i_owner = msg.sender;
    }

    // Function to accept funds to the contract
    function fund() public payable {
        // Check that amount sent to this contract is greater than the minimum required
        // We now change the syntax to 'msg.value.convert()' - this treats msg.value
        // as the 1st argument input to the convert function - the function is called on
        // msg.value which stores a uint256
        require(msg.value.convert() >= MINIMUM_USD, "You didn't send enough money.");
        // To keep track of funders add them to the funders array
        funders.push(msg.sender);
        // To keep track of how much ETH this funder has sent
        addressToAmountFunded[msg.sender] += msg.value;
    }

    // Now we need a function to withdraw the funds from this contract
    function withdraw() public onlyOwner {
        // First modify withdraw function to ensure that only the contract's owner can call the 
        // withdraw function and withdraw funds from the contract
        // Comment this line out now since we're implementing the same functionality using a modifier
        //require(msg.sender == owner, "Attempt to withdraw by someone who is not the owner.");
        // only owner modifier comes after public keyword

        // Loop through the funders array and reset it 
        // (as all funds are being withdrawn we no longer need to keep track of
        // current funders and can reset the array to keep track of any new funders)
        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
            // Get the address of the funder at the current index
            address funder = funders[funderIndex];
            // when we withdraw we reset the value stored here to 0
            addressToAmountFunded[funder] = 0;
        }

        // We still need to reset the array - hypothetical remove everything that is currently stored in it
        funders = new address[](0);
        // ie. funders = a new address array with 0 objects/elements in it

        // We also still need to actually withdraw the funds
        // There are 3 functions that can do this - 
        // the recommended one is the hardest to understand and makes least syntactic sense

        // 1. transfer - 
        // 'this' keyword refers to this whole contract
        // address(this) gets the address of this contract
        // address(this).balance gets the balance of value stored in this contract
        // msg.sender is the address of whoever calls this withdraw function
        // need to typecast msg.sender to make it a payable address - payable(msg.sender)
        // .transfer transfers the balance to the caller's address
        /*payable(msg.sender).transfer(address(this).balance);*/
        // transfer can use a max of 2300 gas - if this is exceeded it will throw an error
        // transfer automatically reverts if the transfer fails

        // 2. send - 
        // send returns a boolean - true if the send is successful, false if not
        // send can also only use 2300 gas but if this is exceeded it will not
        // return an error, it will return boolean false
        // We therefore need to store the returned boolean (in sendSuccess variable) 
        // and require that the send is successful and revert if not
        /*bool sendSuccess = payable(msg.sender).send(address(this).balance);*/
        /*require(sendSuccess, "Withdraw failed!");*/
        // send will only revert if we include the require statement

        // 3. call - 
        // call is the recommeded method because
        // call is the most gas efficient way to send ether
        // call can use all the gas available to it
        // call will not revert if it fails, it will return a boolean

        // call can be used to call almost any other function
        // As we don't actually want to call any function we leave the () empty
        // and indicate this with ""
        // We can add {} prior to () and use them to retreive tha value of the contract's balance
        // call function returns 2 variables - a boolean and a bytes object 'dataReturnded'
        // We only want the boolean, which we will store in callSuccess variable 
        // and require that the call is successful and revert if not
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Withdraw failed!");
    }

    // Modifier creates a keyword that can be added in a function declaration to modify the function
    // the functionality specified in the modifier
    modifier onlyOwner {
        // Comment out to use custom error instead
        //require(msg.sender == i_owner, "Attempt to withdraw by someone who is not the owner.");
        
        // and doing the same thing with a custom error instead
        if (msg.sender != i_owner) {
            revert NotOwner();
        }
        _; // this is where the function code is inserted
    }

    // What happens if someone sends this contract ETH without calling the fund() function?
    // We can use receive and fallback functions
    receive () external payable {
        // We don't use the function keyword when declaring/defining receive functions - 
        // the compiler knows that receive() is a sepcial function
        // it is called whenever a transaction is sent to this contract, even if the value 
        // sent is 0, and there is no calldata specifying a function to call, an address etc.

        // If someone sends this contract ETH without calling the fund() function, we will just 
        // automatically call the fund function for them
        fund();
    }

    fallback() external payable {
        // Similarly no function keyword with fallback function
        // it is called when a transaction is sent and there is some calldata but that calldata
        // does not specify a function etc.

        // If someone sends this contract ETH without calling the fund() function, we will just 
        // automatically call the fund function for them
        fund();
    }

}