// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./RamaToken.sol";

contract RamaStaking {
  mapping(address => uint256) public stakingBalance;
  mapping(address => bool) public isStaking;
  mapping(address => uint256) public startTime;
  mapping(address => uint256) public ramaBalance;

  IERC20 public maticToken;
  RamaToken public ramaToken;

  string public name = "Rama Staking";

  event Stake(address indexed from, uint256 amount);
  event Unstake(address indexed from, uint256 amount);
  event YieldWithdraw(address indexed to, uint256 amount);

  constructor(IERC20 _maticToken, RamaToken _ramaToken) {
    maticToken = _maticToken;
    ramaToken = _ramaToken;
  }

  function stake(uint256 amount) public {
    require(
      amount > 0 && maticToken.balanceOf(msg.sender) >= amount,
      "You cannot stake zero tokens"
    );

    if (isStaking[msg.sender] == true) {
      uint256 toTransfer = getYieldTotal(msg.sender);
      ramaBalance[msg.sender] += toTransfer;
    }

    maticToken.transferFrom(msg.sender, address(this), amount);
    stakingBalance[msg.sender] += amount;
    startTime[msg.sender] = block.timestamp;
    isStaking[msg.sender] = true;
    emit Stake(msg.sender, amount);
  }

  function unstake(uint256 amount) public {
    require(
      isStaking[msg.sender] = true && stakingBalance[msg.sender] >= amount,
      "Nothing to unstake"
    );
    uint256 yieldToTransfer = getYieldTotal(msg.sender);
    startTime[msg.sender] = block.timestamp;
    uint256 balToTransfer = amount;
    amount = 0;
    stakingBalance[msg.sender] -= balToTransfer;
    maticToken.transfer(msg.sender, balToTransfer);
    ramaBalance[msg.sender] += yieldToTransfer;
    if (stakingBalance[msg.sender] == 0) {
      isStaking[msg.sender] = false;
    }
    emit Unstake(msg.sender, balToTransfer);
  }

  function getYieldTime(address user) public view returns (uint256) {
    uint256 end = block.timestamp;
    uint256 totalTime = end - startTime[user];
    return totalTime;
  }

  function getYieldTotal(address user) public view returns (uint256) {
    uint256 time = getYieldTime(user) * 10**18;
    uint256 rate = 86400;
    uint256 timeRate = time / rate;
    uint256 rawYield = (stakingBalance[user] * timeRate) / 10**18;
    return rawYield;
  }

  function withdrawYield() public {
    uint256 toTransfer = getYieldTotal(msg.sender);

    require(
      toTransfer > 0 || ramaBalance[msg.sender] > 0,
      "Nothing to withdraw"
    );

    if (ramaBalance[msg.sender] != 0) {
      uint256 oldBalance = ramaBalance[msg.sender];
      ramaBalance[msg.sender] = 0;
      toTransfer += oldBalance;
    }

    startTime[msg.sender] = block.timestamp;
    ramaToken.mint(msg.sender, toTransfer);
    emit YieldWithdraw(msg.sender, toTransfer);
  }
}
