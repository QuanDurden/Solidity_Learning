// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract CoinFlip {

    // Variables

    address payable player1Address = payable (0x0); // player address variable
    address payable player2Address = payable (0x0); // player address variable

    bytes32 player1Commitment; // player 1 flips coin, true = heads, false = tails
    bool player2Guess; // player 2 guesses which outcome player 1 has, ie. true or false

    uint256 public betAmount; // how much has player 1 bet
    uint256 public betExpiration = 2**256 - 1;


    // Functions

    function player1CommitmentHash (bool choice, uint256 nonce) external pure returns (bytes32) {
        return keccak256(abi.encode(choice, nonce));
    }

    function makeBet (bytes32 hash) external payable {
        // ensure that player 1 hasn't already made a bet yet,
        // ie. player1's address should at this point still be the initial value, 0
        // WHY DOES THIS MATTER?
        require(player1Address == payable (0x0));
        // ensure that player1 has provided a bet value and store it as the bet amount
        require(msg.value > 0);
        betAmount = msg.value;
        // update and store player1's address, ie. update the address to the address from
        // which the function is being called to make the bet
        player1Address = payable(msg.sender);
        // store player1's commitment hash
        player1Commitment = hash;
    }

    function takeBet (bool choice) external payable {
        // ensure that player 1has now placed their bet
        require(player1Address != payable(0x0));
        // ensure that player 2 has not yet accepted the bet, ie. player1's address should 
        // at this point still be the initial value, 0
        require(player2Address == payable(0x0));
        // ensure that the value provided by player 2 when taking the bet via this
        // function is equal to the bet amount
        require(msg.value == betAmount);
        // update and store player2's address, ie. update the address to the address from
        // which the function is being called to take the bet
        player2Address = payable(msg.sender);
        // store player2's guess
        player2Guess = choice;
        // update and store the bet expiration time
        betExpiration = block.timestamp + 24 hours;
    }

    function revealWinner (bool choice, uint256 nonce) external {
        // ensure that player 2 has accepted the bet - player 1 should not reveal their
        // bet choice if player 2 has not accepted it yet
        require(player2Address != payable(0x0));
        // player 1 provides the input to this function - they reveal their bet so that
        // the winner can be determined - ensure that the input, when hashed, matches 
        // player1's commitment
        require(keccak256(abi.encode(choice, nonce)) == player1Commitment);
        // ensure that the bet has not expired yet
        require(block.timestamp < betExpiration);
        // determine the winner and transfer the value stored in the contract to their
        // address
        if (player2Guess == choice) {
            // player 2 wins, pay them
            player2Address.transfer(address(this).balance);
        }
        else {
            // player 1 wins, pay them
            player1Address.transfer(address(this).balance);
        }
    }

    function cancel () external {
        // Allow player 1 to cancel the bet if it has not been accepted
        // ensure that only player 1 can cancel the bet
        require(msg.sender == player1Address);
        // ensure that player 2 has not yet accepted the bet
        require(player2Address == payable(0x0));
        // transfer the value stored in the contract back to player 1
        player1Address.transfer(address(this).balance);
    }

    function timeOut () external {
        // Allow player 2 to win by default if player 1 has not revealed their bet by the 
        // time the bet expires
        // ensure that only player 2 can call this function
        require(msg.sender == player2Address);
        // ensure that the bet has expired
        require(block.timestamp >= betExpiration);
        // transfer the value stored in the contract to player 2
        player2Address.transfer(address(this).balance);
    }
}