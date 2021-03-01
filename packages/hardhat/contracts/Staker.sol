pragma solidity >=0.6.0 <0.7.0;
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";


//import "@openzeppelin/contracts/math/Math.sol";
//import "@openzeppelin/contracts/access/Ownable.sol"; //https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol

contract Staker{

  event Stake(address user, uint256 amount);
  event Withdraw(address user,uint256 amount);

  mapping(address => uint256) public balances;

  uint256 public constant threshold = 1 ether;
  uint256 public deadline = now + 30 seconds;

  ExampleExternalContract public exampleExternalContract;
  bool public flag = false;
  
  constructor(ExampleExternalContract _example) public {
    exampleExternalContract = _example;
  }

  modifier elapsed() {
    require(now-deadline >= 0,"Deadline not elapsed");
    _;
  }

  modifier notCompleted(){
    require(exampleExternalContract.Completed() == false,"External Contract indicates complete");
    _;
  }

  function timeLeft() public view returns(uint256){
    if(deadline>now){
      return deadline - now;
    }
    else {
      return 0;
    }
  }

  function stake() payable external {
    require(timeLeft() > 0,"Deadline elapsed");
    
    balances[msg.sender] += msg.value;
    emit Stake(msg.sender,msg.value); 
    if(timeLeft()>=0 && address(this).balance >= threshold){
      flag = true;
    }
  }

  function execute() public elapsed notCompleted {  
    require(address(this).balance >= threshold,"Threshold not crossed");
    require(flag == true, "Threshold not crossed");
    
    exampleExternalContract.complete{value: address(this).balance}();
  }

  function withdraw() public elapsed notCompleted {
    require(flag==false,"Cannot withdraw, threshold crossed");
    require(balances[msg.sender] > 0, "User didn't deposit");

    uint256 amount = balances[msg.sender];
    balances[msg.sender] = 0;
    msg.sender.transfer(amount);
    emit Withdraw(msg.sender, amount);
  }

}
