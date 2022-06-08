// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;


contract Lottery {

    //----------Variables------------
 
    // Ticket price
    uint constant price = 0.001 ether;

   // Proportion of the balance redistributed to the winner
    uint constant redistributedProportion = 925;  // over 1000

    // Winner of the current lottery
    address public winner;

    // Total number of tickets issued for convenience
    uint public ticketsIssued;

    // Total balance of the smart contract
    uint public contractBalance;

    // When lottery ends
    uint public endTime;

    // Flag that the lottery is open for convenience
    bool public isOpen;

    //----------Events---------------
	
	// We will include events here

    //---------Modifiers---------------
	
	// We will include modifiers here

    //---------Functions----------------
    
    // Create the lottery, closed initially
    constructor(){
        resetLottery();
    }

    function resetLottery() internal returns (bool success) {
        ticketsIssued = 0;
        contractBalance = 0;
        endTime = block.timestamp - 1 hours; // ensure isClosed
        isOpen = false;
        return true;
    }

    // After winners have been declared and awarded, clear the arrays and reset the balances
    function openLottery(uint _duration) public returns (bool success) {
        resetLottery();
        isOpen = true;
        endTime = block.timestamp + _duration;
        return true;
    }
}