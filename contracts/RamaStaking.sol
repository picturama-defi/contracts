// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./RamaToken.sol";

contract RamaStaking is Ownable {
  // mapping token address -> staker address -> amount
  mapping(address => mapping(address => uint256)) public stakingBalance;
  mapping(address => uint256) public uniqueTokensStaked;
  mapping(address => uint256) public timeStaked;
  mapping(address => uint256) public ramaBalance;
  mapping(address => address) public tokenPriceFeedMapping;
  mapping(address => bool) public isStaking;

  address[] public stakers;
  address[] public allowedTokens;

  // Address to that willh old stacked funds
  address public stakedFundsTreasury;

  // Staking threshold
  uint256 public immutable stakingTreshold;
  bool public completed;

  RamaToken ramaToken;

  string public name = "Rama Staking";

  // Staking deadline
  uint256 public deadline = block.timestamp + 63072000 seconds;

  event Stake(address indexed from, uint256 amount, address _token);
  event Unstake(address indexed from, uint256 amount, address _token);

  // Contract's Modifiers
  modifier deadlineReached(bool requireReached) {
    uint256 timeRemaining = timeLeft();
    if (requireReached) {
      require(timeRemaining == 0, "Deadline is not reached yet");
    } else {
      require(timeRemaining > 0, "Deadline is already reached");
    }
    _;
  }

  modifier stakeNotCompleted() {
    require(completed, "staking process already completed");
    _;
  }

  constructor(
    RamaToken _ramaToken,
    uint256 _stakingTreshold,
    address _stakeFundsTreasury
  ) {
    ramaToken = _ramaToken;
    stakingTreshold = _stakingTreshold;
    stakedFundsTreasury = _stakeFundsTreasury;
  }

  function setPriceFeedContract(address _token, address _priceFeed)
    public
    onlyOwner
  {
    tokenPriceFeedMapping[_token] = _priceFeed;
  }

  function getTokenValue(address _token)
    public
    view
    returns (uint256, uint256)
  {
    // priceFeedAddress
    address priceFeedAddress = tokenPriceFeedMapping[_token];
    AggregatorV3Interface priceFeed = AggregatorV3Interface(priceFeedAddress);
    (, int256 price, , , ) = priceFeed.latestRoundData();
    uint256 decimals = uint256(priceFeed.decimals());
    return (uint256(price), decimals);
  }

  function addAllowedTokens(address _token) public onlyOwner {
    allowedTokens.push(_token);
  }

  function tokenIsAllowed(address _token) public view returns (bool) {
    for (
      uint256 allowedTokensIndex = 0;
      allowedTokensIndex < allowedTokens.length;
      allowedTokensIndex++
    ) {
      if (allowedTokens[allowedTokensIndex] == _token) {
        return true;
      }
    }
    return false;
  }

  function stakeTokens(uint256 _amount, address _token)
    public
    deadlineReached(false)
    stakeNotCompleted
  {
    require(
      _amount > 0 && IERC20(_token).balanceOf(msg.sender) >= _amount,
      "You cannot stake zero tokens"
    );
    require(
      tokenIsAllowed(_token),
      "Token is currently not allowed for staking in this platform"
    );

    IERC20(_token).transferFrom(msg.sender, address(this), _amount);
    updateUniqueTokensStaked(msg.sender, _token);
    stakingBalance[_token][msg.sender] =
      stakingBalance[_token][msg.sender] +
      _amount;
    timeStaked[msg.sender] = block.timestamp;
    isStaking[msg.sender] = true;
    if (uniqueTokensStaked[msg.sender] == 1) {
      stakers.push(msg.sender);
    }
    emit Stake(msg.sender, _amount, _token);
  }

  function updateUniqueTokensStaked(address _user, address _token) internal {
    if (stakingBalance[_token][_user] <= 0) {
      uniqueTokensStaked[_user] = uniqueTokensStaked[_user] + 1;
    }
  }

  function issueTokens() public onlyOwner {
    // Issue tokens to all stakers
    for (
      uint256 stakersIndex = 0;
      stakersIndex < stakers.length;
      stakersIndex++
    ) {
      address recipient = stakers[stakersIndex];
      uint256 userTotalValue = getUserTotalValue(recipient);
      ramaToken.mint(msg.sender, userTotalValue);
    }
  }

  function getUserTotalValue(address _user) public view returns (uint256) {
    uint256 totalValue = 0;
    require(uniqueTokensStaked[_user] > 0, "No tokens staked!");
    for (
      uint256 allowedTokensIndex = 0;
      allowedTokensIndex < allowedTokens.length;
      allowedTokensIndex++
    ) {
      totalValue =
        totalValue +
        getUserSingleTokenValue(_user, allowedTokens[allowedTokensIndex]);
    }
    return totalValue;
  }

  function getUserSingleTokenValue(address _user, address _token)
    public
    view
    returns (uint256)
  {
    if (uniqueTokensStaked[_user] <= 0) {
      return 0;
    }
    (uint256 price, uint256 decimals) = getTokenValue(_token);
    return ((stakingBalance[_token][_user] * price) / (10**decimals));
  }

  function unstakeTokens(address _token)
    public
    deadlineReached(false)
    stakeNotCompleted
  {
    require(isStaking[msg.sender] = true, "Nothing to unstake");
    uint256 balToTransfer = stakingBalance[_token][msg.sender];
    require(balToTransfer > 0, "Staking balance cannot be 0");
    require(
      IERC20(_token).balanceOf(address(this)) > balToTransfer,
      "Contract not Funded"
    );
    IERC20(_token).transfer(msg.sender, balToTransfer);
    stakingBalance[_token][msg.sender] = 0;
    uniqueTokensStaked[msg.sender] = uniqueTokensStaked[msg.sender] - 1;
    emit Unstake(msg.sender, balToTransfer, _token);
  }

  function withdrawTokensStaked(address _token)
    public
    deadlineReached(true)
    stakeNotCompleted
  {
    uint256 userBalance = stakingBalance[_token][msg.sender];

    // check if the user has balance to withdraw
    require(userBalance > 0, "You don't have balance to withdraw");

    // reset the balance of the user
    stakingBalance[_token][msg.sender] = 0;

    // Transfer balance back to the user
    (bool sent, ) = msg.sender.call{ value: userBalance }("");
    require(sent, "Failed to send user balance back to the user");
  }

  function transferFundsToTreasury() public deadlineReached(false) onlyOwner {
    require(!completed, "staking process not yet completed");
    uint256 contractBalance = address(this).balance;

    // check the contract has enough ETH to reach the treshold
    require(contractBalance >= stakingTreshold, "Threshold not reached");

    //transfer all the balance to the stakedFundsTreasury  address
    (bool sent, ) = stakedFundsTreasury.call{ value: contractBalance }(
      abi.encodeWithSignature("complete()")
    );
    require(sent, "transfer to stakedFundsTreasury failed");
  }

  function timeLeft() public view returns (uint256 timeleft) {
    if (block.timestamp >= deadline) {
      return 0;
    } else {
      return deadline - block.timestamp;
    }
  }
}
