// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

//import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {
    ExampleExternalContract public exampleExternalContract;

    mapping(address => uint256) public balances;

    event Stake(address, uint256);

    uint256 public constant threshold = 1 ether;

    uint256 public deadline = block.timestamp + 72 hours;

    bool public openForWithdraw = false;

    constructor(address exampleExternalContractAddress) {
        exampleExternalContract = ExampleExternalContract(
            exampleExternalContractAddress
        );
    }

    receive() external payable {
        stake();
    }

    function stake() public payable {
        balances[msg.sender] = msg.value;
        emit Stake(msg.sender, msg.value);
    }

    function execute() public notCompleted {
        require(block.timestamp > deadline, "Stake period is still active");
        if (address(this).balance > threshold) {
            exampleExternalContract.complete{value: address(this).balance}();
        }
        openForWithdraw = true;
    }

    function timeLeft() public view returns (uint256) {
        if (block.timestamp >= deadline) {
            return 0;
        }

        return deadline - block.timestamp;
    }

    function withdraw() public payable notCompleted {
        // Send returns a boolean value indicating success or failure.
        // This function is not recommended for sending Ether.
        require(openForWithdraw, "Staking period is still open");
        address payable _to = _make_payable(msg.sender);
        (bool sent, bytes memory data) = _to.call{value: balances[msg.sender]}(
            ""
        );
        require(sent, "Failed to send Ether");
    }

    function _make_payable(address x) internal pure returns (address payable) {
        return payable(x);
    }

    modifier notCompleted() {
        require(
            !exampleExternalContract.completed(),
            "external contract is not completed."
        );
        _;
    }
    // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
    //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )

    // After some `deadline` allow anyone to call an `execute()` function
    //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value

    // if the `threshold` was not met, allow everyone to call a `withdraw()` function

    // Add a `withdraw()` function to let users withdraw their balance

    // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend

    // Add the `receive()` special function that receives eth and calls stake()
}
