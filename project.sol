// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FutureYieldMarketplace {
    // Define a structure for each student's future yield
    struct StudentYield {
        uint256 yieldAmount; // The amount of future earnings
        uint256 releaseTime; // The time when the yield becomes available
        address studentAddress; // Address of the student
        bool isListed; // Check if it's listed on the marketplace
    }

    // Token representation for future yield (ERC20 standard could be used here)
    mapping(address => uint256) public balances;
    mapping(address => StudentYield) public studentYields;
    
    address public owner;

    event YieldListed(address indexed student, uint256 amount, uint256 releaseTime);
    event YieldPurchased(address indexed buyer, address indexed student, uint256 amount);
    event YieldClaimed(address indexed student, uint256 amount);

    constructor() {
        owner = msg.sender; // The contract creator is the owner
    }

    // Function to list a student's future yield on the marketplace
    function listFutureYield(uint256 _yieldAmount, uint256 _releaseTime) public {
        require(_yieldAmount > 0, "Yield amount must be greater than 0");
        require(_releaseTime > block.timestamp, "Release time must be in the future");
        
        studentYields[msg.sender] = StudentYield({
            yieldAmount: _yieldAmount,
            releaseTime: _releaseTime,
            studentAddress: msg.sender,
            isListed: true
        });

        emit YieldListed(msg.sender, _yieldAmount, _releaseTime);
    }

    // Function for a buyer to purchase future yield
    function purchaseYield(address _student) public payable {
        require(studentYields[_student].isListed, "Yield not listed");
        require(msg.value == studentYields[_student].yieldAmount, "Incorrect payment amount");

        // Transfer payment to student
        payable(_student).transfer(msg.value);

        // Mark the yield as purchased
        studentYields[_student].isListed = false;

        emit YieldPurchased(msg.sender, _student, msg.value);
    }

    // Function for students to claim their future yield after the release time
    function claimYield() public {
        require(block.timestamp >= studentYields[msg.sender].releaseTime, "Yield not available yet");
        require(studentYields[msg.sender].yieldAmount > 0, "No yield to claim");

        uint256 yieldAmount = studentYields[msg.sender].yieldAmount;
        studentYields[msg.sender].yieldAmount = 0;

        // Transfer yield to the student
        payable(msg.sender).transfer(yieldAmount);

        emit YieldClaimed(msg.sender, yieldAmount);
    }

    // Allow the owner to withdraw any contract balance
    function withdraw(uint256 amount) public {
        require(msg.sender == owner, "Only owner can withdraw");
        payable(owner).transfer(amount);
    }

    // Fallback function to accept Ether
    receive() external payable {}
}

