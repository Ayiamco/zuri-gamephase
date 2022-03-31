pragma solidity 0.8.4;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {
    event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);

    YourToken public yourToken;

    uint256 public constant tokensPerEth = 100;

    constructor(address tokenAddress) {
        yourToken = YourToken(tokenAddress);
    }

    function buyTokens() public payable {
        uint256 tokens = msg.value * tokensPerEth;
        yourToken.transfer(msg.sender, tokens);
        emit BuyTokens(msg.sender, msg.value, tokens);
    }

    function withdraw() public payable onlyOwner {
        address payable _to = _make_payable(msg.sender);
        (bool sent, bytes memory data) = _to.call{value: msg.value}("");
        require(sent, "Failed to send Ether");
    }

    function _make_payable(address x) internal pure returns (address payable) {
        return payable(x);
    }

    function sellTokens(uint256 amount) public payable {
        yourToken.transferFrom(msg.sender, address(this), amount);
        address payable payableAddress = _make_payable(msg.sender);
        (bool sent, bytes memory data) = payableAddress.call{
            value: amount / tokensPerEth
        }("");
        require(sent, "Failed to send Ether");
    }
}
