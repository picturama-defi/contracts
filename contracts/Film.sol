// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "hardhat/console.sol";

contract Film {
    uint256 public targetFund;
    uint256 public amountFundedSoFar;
    uint256 public fundNo = 1;
    address public filmOwner;
    uint256 public filmStartTime;
    uint256 public factor = 1000;

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
        bool isClaimed;
        uint256 claimableYield;
    }

    struct UserFundDetails {
        uint256 userFund;
        uint256 claimableYield;
    }

    struct FilmFundDetails {
        uint256 targetFund;
        uint256 fundedSoFar;
    }

    Fund[] public funds;

    function fund(uint256 amount, address sender) public payable {
        if (amount > getRemainingAmountToBeFunded()) {
            revert("Excess fund");
        }

        bool fundedByUser = isAlreadyFunded(sender);

        if (fundedByUser) {
            revert("Already funded");
        }

        uint256 minimum = 365;
        uint256 extraIncentive = 100;

        uint256 yield = (amount * minimum) /
            1000 +
            (extraIncentive *
                (
                    (amount -
                        amount *
                        ((block.timestamp - filmStartTime) /
                            (2 * 365 * 24 * 60 * 60)))
                )) /
            1000;

        Fund memory newFund = Fund({
            amount: amount,
            funder: sender,
            startTime: block.timestamp,
            isClaimed: false,
            claimableYield: yield
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
                UserFundDetails(
                    funds[index].amount,
                    funds[index].claimableYield
                );
        } else {
            revert("Invalid request");
        }
    }

    function getFilmFundDetails() public view returns (FilmFundDetails memory) {
        return FilmFundDetails(targetFund, amountFundedSoFar);
    }

    function claimYield(address sender) public view returns (uint256) {
        uint256 index = findFundIndex(sender);
        if (!funds[index].isClaimed) {
            return funds[index].claimableYield;
        } else {
            revert("Reward already claimed");
        }
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
        funds[index].isClaimed = true;
        funds[index].claimableYield = 0;
    }
}
