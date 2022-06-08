// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;


contract Lottery {

    //----------Variables------------

    // Mapping of tickets issued to each address
    mapping (address => uint) public ticketHolders;
    address payable[] public holders;

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
    constructor() {
        resetLottery();
    }

    // Fallback function calls buyTickets
    receive() external payable {
        buyTickets();
    }

    // Award users tickets for eth, 1 finney = 1 ticket
    function buyTickets() public payable returns (bool success) {
        // Grant the player the number of tickets bought
        ticketHolders[msg.sender] = msg.value / price;

        // Increment the total number of tickets
        ticketsIssued += ticketHolders[msg.sender];
        
        // Add the player to the keys
        holders.push(payable(msg.sender));
        
        // Increment the lottery's balance
        contractBalance += msg.value;
        
        return true;
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

    function getTicketBalance(address _account) public view returns (uint balance) {
        return ticketHolders[_account];
    }
}
