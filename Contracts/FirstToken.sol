// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract FirstToken is ERC20 {
    

    // VARIABLES

    // Token properties
    string constant tokenName = "FirstToken";
    string constant tokenSymbol = "FTK";

    // Initialise supply
    uint256 _totalSupply = 0; // initial supply is 0

    // Initial token purchase and sale prices are 0 - technically, according to the bonding 
    // curve we are using, when the supply = 0, ie. there are no tokens in circulation, the 
    // price should be 1
    // However, this makes no real world sense - no-one will pay 1 wei for nothing
    uint256 public purchasePrice = 0;
    uint256 public salePrice = 0;
    uint256 hypotheticalPrice = 0;

    // parameters of the linear bonding curve used to calculate price
    uint256 gradient = 1;
    uint256 intercept = 1;

    // Also need a mapping to store user balances
    mapping(address => uint256) private balance;


    // CONSTRUCTOR

    // token name = FirstToken
    // token symbol = FTK
    // don't need the constructor to do anything else
    constructor() ERC20(tokenName, tokenSymbol) {}


    //FUNCTIONS

    // Function to calculate token purchase purchase price using bonding curve
    function getPurchasePrice(uint256 quantity) public returns(uint256) {
        // how many tokens does user want - need quantity
        // how many tokens are there already - need totalSupply

        // reset price to 0 so that the contract is only calculating price of new tokens
        // eg. with bonding curve 'tokenPrice = (1 * totalSupply) + 1', price of 1st 5
        // tokens is 20 wei, price of next 5 tokens is 45 wei, however, if price is not reset
        // it will still be 20 and the next price will be caclulated as 20 + 45 = 65
        purchasePrice = 0;

        // Use a for loop to sum the spot prices of each individual token
        // token counter variable 'supply' is the current number of tokens
        // initialise 'supply' to '1 + _totalSupply' - we are only interested in price of
        // at least 1 token, eg. when total supply is 0 we need to add 1, if total supply
        // is 5 we want price of token 6 onward
        // price we want is for the requested quantity of tokens over and above the current
        // total supply - 'i <= quantity + _totalSupply'
        for(uint256 supply = 1 + _totalSupply; supply <= quantity + _totalSupply; supply++) {
            // spot price of individual token is calculated using linear bonding curve defined
            // by equation 'tokenPrice = (1 * supply) + 1'
            uint256 spot_price = (gradient * supply) + intercept;
            // add each token's spot price to total price of all requested tokens
            purchasePrice += spot_price;
        }

        return purchasePrice;
    }

    // Function to use bonding curve to calculate current token price a user can expect to
    // receive for selling tokens
    function getSalePrice(uint256 quantity) public returns(uint256) {
        // how many tokens does user want to sell - need quantity
        // how many tokens are there already - need totalSupply

        if (quantity > _totalSupply && _totalSupply > 0) {
            uint256 hypotheticalSupply = quantity;
            salePrice = getHypotheticalPrice(quantity, hypotheticalSupply);
        }
        else {
            // If there are some tokens in circulation, calculate the sale price for the requested
            // number of tokens
            // if there are no tokens in circulation no tokens can be sold and sale price = 0
            if (_totalSupply > 0) {
                // reset sale price to 0
                salePrice = 0;
                // Use a for loop to sum the spot prices of each individual token
                // starting at current '_totalSupply' and counting down to '_totalSupply - quantity'
                // because 'quantity' tokens will be sold back to the contract and removed from
                // _totalSupply by burning
                for(uint256 supply = _totalSupply; supply > _totalSupply - quantity; supply--) {
                    uint256 spot_price = (gradient * supply) + intercept;
                    salePrice += spot_price;
                }
            }
            else {
                salePrice = 0;
            }
        }

        return salePrice;
    }

    function getHypotheticalPrice(uint256 quantity, uint256 hypotheticalSupply) internal returns(uint256) {

        hypotheticalPrice = 0;
        // Use a for loop to sum the spot prices of each individual token
        // starting at current '_totalSupply' and counting down to '_totalSupply - quantity'
        // because 'quantity' tokens will be sold back to the contract and removed from
        // _totalSupply by burning
        for(uint256 supply = hypotheticalSupply; supply > hypotheticalSupply - quantity; supply--) {
            uint256 spot_price = (gradient * supply) + intercept;
            hypotheticalPrice += spot_price;
        }

        return hypotheticalPrice;
    }

    // Function to mint/enable buying of new tokens
    function buyTokens(uint256 quantity) external payable {

        address recipient = msg.sender; // address to send the bought tokens to

        // require that some tokens are being bought
        require(quantity > 0, "Token quantity must be positive");
        // get the price of the requested quantity of tokens
        purchasePrice = getPurchasePrice(quantity);
        // require that the user has sent enough money
        require(msg.value >= purchasePrice, "Insufficient WEI sent");

        // mint the requested/bought tokens and send them to the user
        // _mint() function from the imported contract calls _update()
        // which updates the total supply and balance of user
        _mint(recipient, quantity);
        // still need to update the value of _totalSupply variable in this contract
        // by calling totalSupply() function from imported contract
        _totalSupply = totalSupply();
        // and update user's balance in this contract
        balance[recipient] = balanceOf(recipient);
    }

    // Function to burn/enable selling of tokens
    function sellTokens(uint256 quantity) external {

        address seller = msg.sender; // address selling tokens

        // require that some tokens are being sold
        require(quantity > 0, "Token quantity must be positive");
        // require that the user has enough tokens
        require(balance[seller] >= quantity, "Your balance is insufficient");
        // get the price of the requested quantity of tokens
        salePrice = getSalePrice(quantity);

        // burn the sold tokens
        // _burn() function from the imported contract calls _update()
        // which updates the total supply and balance of seller
        _burn(seller, quantity);
        // still need to update the value of _totalSupply variable in this contract
        // by calling totalSupply() function from imported contract
        _totalSupply = totalSupply();
        // and update seller's balance in this contract
        balance[seller] = balanceOf(seller);
        // pay the seller
        (bool callSuccess, ) = payable(seller).call{value: salePrice}("");
        require(callSuccess, "Payment failed");
    }

}