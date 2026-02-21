// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract FirstToken is ERC20 {
    

    // VARIABLES

    // Token properties
    string constant tokenName = "FirstToken";
    string constant tokenSymbol = "FTK";

    // Initialise supply and price
    uint256 _totalSupply = 0; // initial supply is 0
    // initial price is 0 - technically, according to the bonding curve we are using,
    // when the supply = 0, ie. there are no tokens in circulation, the price should be 1
    // however, this makes no real world sense
    uint256 public price = 0;

    // Also need a mapping to store user balances
    mapping(address account => uint256) private balance;


    // CONSTRUCTOR

    // token name = FirstToken
    // token symbol = FTK
    // don't need the constructor to do anything else
    constructor() ERC20(tokenName, tokenSymbol) {}


    //FUNCTIONS

    // function to define the bonding curve
    // basic linear bonding curve: y = mx + c
    //function bondingCurve () public pure {
    //    uint8 gradient = 1;
    //    uint8 base_price = 1;
    //}

    // Function to calculate token purchase price using bonding curve
    function getPurchasePrice(uint256 quantity) public returns(uint256) {
        // how many tokens does user want - need quantity
        // how many tokens are there already - need totalSupply

        // parameters of the linear bonding curve used to calculate price
        uint256 gradient = 1;
        uint256 intercept = 1;

        // reset price to 0 so that the contract is only calculating price of new tokens
        // eg. with bonding curve 'tokenPrice = (1 * totalSupply) + 1', price of 1st 5
        // tokens is 20 wei, price of next 5 tokens is 45 wei, however, if price is not reset
        // it will still be 20 and the next price will be caclulated as 20 + 45 = 65
        price = 0;

        // Use a for loop to sum the spot prices of each individual token
        // token counter variable 'supply' is the current number of tokens
        // initialise 'supply' to '1 + totalSupply' - we are only interested in price of
        // at least 1 token, eg. when total supply is 0 we need to add 1, if total supply
        // is 5 we want price of token 6 onward
        // price we want is for the requested quantity of tokens over and above the current
        // total supply - 'i <= quantity + totalSupply'
        for(uint256 supply = 1 + _totalSupply; supply <= quantity + _totalSupply; supply++) {
            // spot price of individual token is calculated using linear bonding curve defined
            // by equation 'tokenPrice = (1 * supply) + 1'
            uint256 spot_price = (gradient * supply) + intercept;
            // add each token's spot price to total price of all requested tokens
            price += spot_price;
        }

        return price;
    }

    // Function to mint new tokens and send them to a buyer
    function mint(address recipient, uint256 quantity) internal {
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

    // Function to mint/enable buying of new tokens
    function buyTokens(uint256 quantity) external payable {

        address recipient = msg.sender; // address to send the bought tokens to

        // require that some tokens are being bought
        require(quantity > 0, "Token quantity must be positive");
        // get the price of the requested quantity of tokens
        price = getPurchasePrice(quantity);
        // require that the user has sent enough money
        require(msg.value >= price, "Insufficient WEI sent");

        // mint the requested/bought tokens and send them to the user
        mint(recipient, quantity);
        // _mint() function from the imported contract calls _update()
        // which updates the total supply and balance of user
        //_mint(recipient, quantity);
        // still need to update the value of _totalSupply variable in this contract
        // by calling totalSupply() function from imported contract
        //_totalSupply = totalSupply();
        // and update user's balance in this contract
        //balance[recipient] = balanceOf(recipient);
    }

    // Function to calculate token sale price using bonding curve

    // Function to burn/enable selling of tokens
    function sellTokens(uint256 quantity) external payable {

        address seller = msg.sender; // address selling tokens

        // require that some tokens are being sold
        require(quantity > 0, "Token quantity must be positive");
        // require that the user has enough money
        require(balance[seller] >= quantity, "Your balance is insufficient");
        // get the price of the requested quantity of tokens
        price = getPurchasePrice(quantity);

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
        (bool callSuccess, ) = payable(seller).call{value: price}("");
        require(callSuccess, "Payment failed");
        // if, having burned the seller's tokens and removed them from the seller's
        // balance, the payment fails, mint the burned tokens again and return them
        // to the seller
        if(!callSuccess) {
            mint(seller, quantity);
        }
    }

}