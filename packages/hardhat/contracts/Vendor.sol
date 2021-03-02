pragma solidity >=0.6.0 <0.7.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {

  YourToken yourToken;
  event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);

  uint256 public constant tokensPerEth = 100;

  constructor(address tokenAddress) public {
    yourToken = YourToken(tokenAddress);
  }

  //ToDo: create a payable buyTokens() function:
  function buyTokens() external payable{
    yourToken.transfer(msg.sender,msg.value*tokensPerEth);
    emit BuyTokens(msg.sender, msg.value, tokensPerEth*msg.value);
  }

  //ToDo: create a sellTokens() function:
  function sellTokens( address user, uint256 amount) public{
    yourToken.transfer(user,amount);
  }

  //ToDo: create a withdraw() function that lets the owner, you can 
  //use the Ownable.sol import above:
  function withdraw() onlyOwner public {
    uint256 amount = yourToken.balanceOf(address(this));
    yourToken.transfer(owner(),amount);
  }
}
