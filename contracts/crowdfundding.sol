// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Crowdfunding {
    address public owner;
    uint public fundingGoal;
    uint public amountRaised;
    bool public goalReached;
    bool public closed;
    
    mapping(address => uint) public contributions;

    event Funded(address contributor, uint amount);
    event GoalReached(address owner, uint totalAmount);
    event Withdrawn(address owner, uint amount);

    constructor(uint _fundingGoal) {
        owner = msg.sender;
        fundingGoal = _fundingGoal;
        amountRaised = 0;
        goalReached = false;
        closed = false;
    }

    // Function 1: contribute to the crowdfunding campaign
    function contribute() external payable {
        require(!closed, "Campaign is closed");
        require(msg.value > 0, "Contribution must be > 0");

        contributions[msg.sender] += msg.value;
        amountRaised += msg.value;
        emit Funded(msg.sender, msg.value);

        if (amountRaised >= fundingGoal) {
            goalReached = true;
            emit GoalReached(owner, amountRaised);
        }
    }

    // Function 2: withdraw funds (only owner, only if goal reached)
    function withdraw() external {
        require(msg.sender == owner, "Only owner can withdraw");
        require(goalReached, "Funding goal not reached yet");
        require(!closed, "Campaign already closed");

        closed = true;
        uint amount = amountRaised;
        amountRaised = 0;
        (bool success, ) = owner.call{ value: amount }("");
        require(success, "Withdrawal failed");
        emit Withdrawn(owner, amount);
    }

    // Function 3: refund contributors if campaign failed
    function refund() external {
        require(!closed, "Campaign closed");
        require(!goalReached, "Goal was reached");
        uint contributed = contributions[msg.sender];
        require(contributed > 0, "No contributions to refund");

        contributions[msg.sender] = 0;
        (bool success, ) = msg.sender.call{ value: contributed }("");
        require(success, "Refund failed");
    }
}
