// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "hardhat/console.sol";

contract Film {
  uint256 public targetFund;
  uint256 public amountFundedSoFar;
  uint256 public fundNo = 1;
  address public filmOwner;
  uint256 public filmStartTime;
  uint256 public factor = 10000;

  constructor(uint256 _targetFund, address _filmOwner) {
    targetFund = _targetFund;
    filmOwner = _filmOwner;
    amountFundedSoFar = 0;
    filmStartTime = block.timestamp;
  }

  struct Fund {
    uint256 amount;
    address funder;
    uint256 startTime;
    bool isFundsLocked;
  }

  struct UserFundDetails {
    uint256 userFund;
    uint256 yieldGenerated;
  }

  struct FilmFundDetails {
    uint256 targetFund;
    uint256 fundedSoFar;
  }

  // unstake -> Matic only

  // withdraw (automatically) -> Matic + Rama

  Fund[] public funds;

  function fund(uint256 amount, address sender) public payable {
    if (amount > getRemainingAmountToBeFunded()) {
      revert("Excess fund");
    }

    bool fundedByUser = isAlreadyFunded(sender);

    if (fundedByUser) {
      revert("Already funded");
    }

    Fund memory newFund = Fund({
      amount: amount,
      funder: sender,
      startTime: block.timestamp,
      isFundsLocked: false
    });

    amountFundedSoFar = amountFundedSoFar + amount;
    funds.push(newFund);
  }

  function getRemainingAmountToBeFunded() public view returns (uint256) {
    return targetFund - amountFundedSoFar;
  }

  function removeFund(uint256 _amount, address sender) public {
    // if (amountFundedSoFar < targetFund) {}

    // if (amountFundedSoFar >= targetFund) {
    //   revert("Film is already in production you cannot remove funds");
    // }
    uint256 indexOfItemToBeDeleted = findFundIndex(sender);

    if (indexOfItemToBeDeleted != 0) {
      deleteItemInArray(indexOfItemToBeDeleted);
    }
  }

  function deleteItemInArray(uint256 index) public {
    require(index < funds.length, "Invalid request");
    funds[index] = funds[funds.length - 1];
    funds.pop();
  }

  function isAlreadyFunded(address sender) public view returns (bool) {
    for (uint256 i = 0; i < funds.length; i++) {
      if (funds[i].funder == sender) {
        return true;
      }
    }
    return false;
  }

  function getFunds() public view returns (Fund[] memory) {
    return funds;
  }

  function getFundOfUser(address userAddress)
    public
    view
    returns (UserFundDetails memory)
  {
    bool isFundedByUser = isAlreadyFunded(userAddress);

    if (isFundedByUser) {
      uint256 index = findFundIndex(userAddress);
      return
        UserFundDetails(funds[index].amount, calculateYieldTotal(userAddress));
    } else {
      revert("Invalid request");
    }
  }

  function getFilmFundDetails() public view returns (FilmFundDetails memory) {
    return FilmFundDetails(targetFund, amountFundedSoFar);
  }

  function timeFromStartOfProjectToFunding(uint256 index)
    public
    view
    returns (uint256)
  {
    console.log(funds[index].startTime);
    console.log(filmStartTime);

    return funds[index].startTime - filmStartTime;
  }

  function calculateYieldTotal(address sender) public view returns (uint256) {
    uint256 index = findFundIndex(sender);
    return
      funds[index].amount * (factor / timeFromStartOfProjectToFunding(index));
  }

  function claimYield(address sender) public view returns (uint256) {
    uint256 yield = calculateYieldTotal(sender);
    return yield;
  }

  function findFundIndex(address sender) public view returns (uint256) {
    for (uint256 i = 0; i < funds.length; i++) {
      if (funds[i].funder == sender) {
        return i;
      }
    }
    revert("Invalid request");
  }

  function lockFund(address sender) public {
    uint256 index = findFundIndex(sender);
    funds[index].isFundsLocked = true;
  }
}
