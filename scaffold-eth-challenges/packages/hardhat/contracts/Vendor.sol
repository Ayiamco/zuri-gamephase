pragma solidity 0.8.4;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {
    event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);

    YourToken public yourToken;

    uint256 public constant tokensPerEth = 100;

    uint256 tokenPrice = 1 ether / tokensPerEth; //token sold at 100 Tokens per ETH

    constructor(address tokenAddress) {
        yourToken = YourToken(tokenAddress);
    }

    function buyTokens() public payable {
        uint256 tokens = msg.value / tokenPrice;
        yourToken.transfer(msg.sender, tokens);
        emit BuyTokens(msg.sender, msg.value, tokens);
    }

    function withdraw() public onlyOwner {
        yourToken.transfer(msg.sender, 1000);
    }

    // ToDo: create a sellTokens() function:
}
