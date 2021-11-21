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

  RamaToken ramaToken;

  string public name = "Rama Staking";

  event Stake(address indexed from, uint256 amount, address _token);
  event Unstake(address indexed from, uint256 amount, address _token);

  constructor(RamaToken _ramaToken) {
    ramaToken = _ramaToken;
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

  function stakeTokens(uint256 _amount, address _token) public {
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

  function issueRamaTokens() public onlyOwner {
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

  function unstakeTokens(address _token) public {
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
}
