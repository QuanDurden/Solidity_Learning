// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

library PriceConverter {

        // Function in a library MUST be internal

        function getPrice() internal pure returns(uint256) {
            
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


    function convert(uint256 ethAmount) internal pure returns(uint256) {
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