// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "hardhat/console.sol";

contract Film {
    uint256 internal targetFund;
    uint256 internal amountFundedSoFar;
    uint256 internal fundNo = 1;
    address internal filmOwner;
    uint256 internal filmStartTime;
    uint256 internal factor = 1000;

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

    Fund[] internal funds;

    function fund(uint256 amount, address sender) internal {
        if (amount > getRemainingAmountToBeFunded()) {
            revert("Excess fund");
        }

        bool fundedByUser = isAlreadyFunded(sender);

        if (fundedByUser) {
            revert("Already funded");
        }

        uint256 minimum = 375;
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

    function getRemainingAmountToBeFunded() internal view returns (uint256) {
        return targetFund - amountFundedSoFar;
    }

    function removeFund(address sender) internal returns (uint256) {
        uint256 indexOfItemToBeDeleted = findFundIndex(sender);

        if (funds[indexOfItemToBeDeleted].amount == 0) {
            revert("No funds to withdraw");
        }

        if (funds[indexOfItemToBeDeleted].isClaimed == true) {
            revert("Rama tokens are claimed");
        }

        if (amountFundedSoFar >= targetFund) {
            revert("Film is in production");
        }

        uint256 amountToWithdraw = funds[indexOfItemToBeDeleted].amount;

        amountFundedSoFar = amountFundedSoFar - amountToWithdraw;

        deleteItemInArray(indexOfItemToBeDeleted, funds.length);

        return amountToWithdraw;
    }

    function deleteItemInArray(uint256 index, uint256 length) internal {
        if (length == 1) {
            funds.pop();
        } else {
            funds[index] = funds[funds.length - 1];
            funds.pop();
        }
    }

    function isAlreadyFunded(address sender) internal view returns (bool) {
        for (uint256 i = 0; i < funds.length; i++) {
            if (funds[i].funder == sender) {
                return true;
            }
        }
        return false;
    }

    function getFunds() internal view returns (Fund[] memory) {
        return funds;
    }

    function getFundOfUser(address userAddress)
        internal
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

    function getFilmFundDetails()
        internal
        view
        returns (FilmFundDetails memory)
    {
        return FilmFundDetails(targetFund, amountFundedSoFar);
    }

    function claimYield(address sender) internal view returns (uint256) {
        uint256 index = findFundIndex(sender);
        if (!funds[index].isClaimed) {
            return funds[index].claimableYield;
        } else {
            revert("Reward already claimed");
        }
    }

    function findFundIndex(address sender) internal view returns (uint256) {
        for (uint256 i = 0; i < funds.length; i++) {
            if (funds[i].funder == sender) {
                return i;
            }
        }
        revert("Invalid request");
    }

    function lockFund(address sender) internal {
        uint256 index = findFundIndex(sender);
        funds[index].isClaimed = true;
        funds[index].claimableYield = 0;
    }
}
