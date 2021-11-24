// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "hardhat/console.sol";

contract Film {
    uint256 public targetFund;
    uint256 public amountFundedSoFar;
    uint256 public fundNo = 1;
    address public filmOwner;

    constructor(uint256 _targetFund, address _filmOwner) {
        targetFund = _targetFund;
        filmOwner = _filmOwner;
        amountFundedSoFar = 0;
    }

    struct Fund {
        uint256 amount;
        address funder;
        uint256 startTime;
    }

    Fund[] public funds;

    function fund(uint256 amount, address sender) public {
        if (amount > getRemainingAmountToBeFunded()) {
            revert("Excess fund");
        }

        Fund memory newFund = Fund({
            amount: amount,
            funder: sender,
            startTime: block.number
        });

        amountFundedSoFar = amountFundedSoFar + amount;
        funds.push(newFund);
    }

    function getRemainingAmountToBeFunded() public view returns (uint256) {
        return targetFund - amountFundedSoFar;
    }

    function removeFund(address sender) public {
        uint256 indexOfItemToBeDeleted = findFundIndex(sender);

        if (indexOfItemToBeDeleted != 0) {
            deleteItemInArray(indexOfItemToBeDeleted);
        }
    }

    function deleteItemInArray(uint256 index) internal {
        require(index < funds.length, "Invalid request");
        funds[index] = funds[funds.length - 1];
        funds.pop();
    }

    function findFundIndex(address sender) public view returns (uint256) {
        for (uint256 i = 0; i < funds.length; i++) {
            if (funds[i].funder == sender) {
                return i;
            }
        }
        revert("Invalid request");
    }

    function getFunds() public view returns (Fund[] memory) {
        return funds;
    }
}
