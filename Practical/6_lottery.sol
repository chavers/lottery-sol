// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "./owner.sol";

contract Lottery is Owner {

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

    // Event for when tickets are bought
    event TicketsBought(address indexed _from, uint _quantity);

    // Event for declaring the winner
    event AwardWinnings(address _to, uint _winnings);

    // Event for lottery reset
    event ResetLottery();

    //---------Modifiers---------------

    // Checks if still in lottery contribution period
    modifier isOngoing() {
        require(block.timestamp < endTime, "Lottery is closed");
        isOpen = true;
        _;
    }

    // Checks if lottery has finished
    modifier isClosed() {
        require(block.timestamp > endTime, "Lottery still ongoing");
        isOpen = false;
        _;
    }

    //---------Functions----------------
    
    // Create the lottery, closed initially
    constructor() Owner(){
        resetLottery();
    }

    // Fallback function calls buyTickets
    receive() external payable {
        buyTickets();
    }

    // Award users tickets for eth, 1 finney = 1 ticket
    function buyTickets() public payable isOngoing returns (bool success) {
        // Grant the player the number of tickets bought
        ticketHolders[msg.sender] = msg.value / price;

        // Increment the total number of tickets
        ticketsIssued += ticketHolders[msg.sender];
        
        // Add the player to the keys
        holders.push(payable(msg.sender));
        
        // Increment the lottery's balance
        contractBalance += msg.value;
        
        // Log event
        emit TicketsBought(msg.sender, ticketHolders[msg.sender]);
        
        return true;
    }

    function resetLottery() internal returns (bool success) {
        ticketsIssued = 0;
        contractBalance = 0;
        endTime = block.timestamp - 1 hours; // ensure isClosed
        isOpen = false;
        emit ResetLottery();
        return true;
    }

    // After winners have been declared and awarded, clear the arrays and reset the balances
    function openLottery(uint _duration) public isClosed isOwner returns (bool success) {
        resetLottery();
        isOpen = true;
        endTime = block.timestamp + _duration;
        return true;
    }

    // This will distribute the correct winnings to each winner
    function awardWinnings(address payable _winner) internal returns (bool success) {
        uint gain = contractBalance * redistributedProportion / 1000;
        _winner.transfer(gain);
        emit AwardWinnings(_winner, gain);
        payable(this.getOwner()).transfer(contractBalance - gain);
        resetLottery();
        return true;
    }

    // Generate the winners by random using tickets bought as weight
    function pickWinner() public isClosed returns (uint winningTicket) {
        uint randNum = uint(keccak256(abi.encode(block.difficulty, block.timestamp, holders))) % ticketsIssued;
        uint cumsum = 0;
        uint idx;
        for (idx=0; idx < holders.length; idx++) {
            cumsum += ticketHolders[holders[idx]];
            if (cumsum > randNum) {
                break;
            }
        }
        winner = holders[idx];
        awardWinnings(payable(winner));
        return randNum;
    }

    function getTicketBalance(address _account) public view returns (uint balance) {
        return ticketHolders[_account];
    }
}