// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

contract FundMe {

    // Minimum amount of USD that can be sent to the contract
    uint256 minimumUSD = 50 * 1e18;

    // Create an array to store addresses of funders
    address[] public funders;
    // Create a mapping to store the amount of ETH sent by each funder
    mapping(address => uint256) public addressToAmountFunded;

    function fund() public payable {
        // 1. How do we send money (ETH) to this contract?
        // Use 'msg.value' global keyword - 
        // this is the value that is sent by the user when they call the function

        // If we want to set a minimum amount that the user can send, we can use 'require' keyword
        //eg. require(msg.value > 1e18, "You didn't send enough Ether.");
        // the stuff in quotes is the 'revert' error message

        // What is reverting - 
        // it undoes any actions executed before the revert and sends remaining gas back

        //require(msg.value >= minimumUSD, "You didn't send enough money.");

        // Update this again to use convert function to get sent ETH values into USD
        require(convert(msg.value) >= minimumUSD, "You didn't send enough money.");

        // To keep track of funders add them to the funders array
        // 'msg.sender' is an always available global keyword - 
        // it holds the address of the person who calls the function to send the transaction
        funders.push(msg.sender);
        // To keep track of how much ETH this funder has sent
        addressToAmountFunded[msg.sender] += msg.value;
    }


    function getPrice() public pure returns(uint256) {
        // Declare varaible to store the price
        uint256 price;
        
        // 2. How do we get the price of ETH in USD?
        // We need to use a Chainlink Price Feed contract
        // We need the address of the contract, 
        // which we can get from https://docs.chain.link/docs/ethereum-addresses/
        // We also need the ABI of the contract - 
        // we can use an interface for this, 
        // which we can get from github.com/smartcontractkit/chainlink

        // I'm not going to do all that at this stage
        // so will just set an approximate value
        price = 3000 * 10**18;
        // 18 decimal places needed as prices are in Wei & 1 Wei = 1e18 ETH
        return price;
    }


    function convert(uint256 ethAmount) public pure returns(uint256) {
        // We wnat this function to convert the supplied ETH amount to USD
        // We can then check that the value sent to the contract is greater than 50 USD

        // first get the price of ETH in terms of USD
        uint256 ethPrice = getPrice();

        // then calculate the value of the supplied ETH amount in USD
        uint256 usdAmount = ethAmount * ethPrice / 10**18;

        // return the USD amount
        return usdAmount;
    }

}