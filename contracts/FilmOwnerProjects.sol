// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "hardhat/console.sol";

contract FilmOwnerProjects {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    // All the film owners currently in the platform
    address[] private filmOwners;

    // As we add new projects, this is incremented to keep track of it
    uint256 private filmCount = 0;

    // Film owner mapping to projects that they own
    mapping(address => uint256[]) public filmOwnerToFilmIdsMapping;

    // Project object that keeps track of target fund and funders and their contributions
    struct FilmFundingDetails {
        uint256 targetAmount;
        mapping(address => uint256) funderAddressToAmountMapping;
        address[] funders;
    }

    struct FilmData {
        uint256 targetAmount;
        uint256 totalFunded;
        uint256 id;
    }

    // project id to project details mapping
    mapping(uint256 => FilmFundingDetails) public filmIdToDetailsMapping;

    // Adds a new film to the platform
    function addFilm(address filmOwnerAddress, uint256 fundingGoal) public {
        require(owner == msg.sender, "Unauthorised request");

        if (!doesItemExist(filmOwnerAddress, filmOwners)) {
            addFilmOwner(filmOwnerAddress);
        }

        filmCount = filmCount + 1;

        // Adding a new film
        filmOwnerToFilmIdsMapping[filmOwnerAddress].push(filmCount);
        FilmFundingDetails storage newFilmDetails = filmIdToDetailsMapping[
            filmCount
        ];
        newFilmDetails.targetAmount = fundingGoal;
    }

    // Add a new new film owner to the film owners list
    function addFilmOwner(address filmOwnerAddress) private {
        if (doesItemExist(filmOwnerAddress, filmOwners)) {
            filmOwnerToFilmIdsMapping[filmOwnerAddress] = new uint256[](100);
        }
    }

    // Checks if the film owner is already present in the platform
    function doesItemExist(address item, address[] memory items)
        private
        pure
        returns (bool)
    {
        for (uint256 i = 0; i < items.length; i += 1) {
            if (items[i] == item) {
                return true;
            }
        }
        return false;
    }

    function getProjectsOwned(address ownerAddress)
        public
        view
        returns (uint256[] memory)
    {
        return filmOwnerToFilmIdsMapping[ownerAddress];
    }

    function getAllProjects() public view returns (FilmData[] memory) {
        FilmData[] memory filmDataList = new FilmData[](filmCount);
        for (uint256 id = 1; id <= filmCount; id++) {
            FilmData memory filmData = FilmData(
                filmIdToDetailsMapping[id].targetAmount,
                getTotalFundedAmount(id),
                id
            );
            filmDataList[id - 1] = filmData;
        }
        return filmDataList;
    }

    function fundFilm(uint256 id) public payable {
        require(id <= filmCount && id >= 0, "Invalid film id");

        if (!doesItemExist(msg.sender, filmIdToDetailsMapping[id].funders)) {
            filmIdToDetailsMapping[id].funders.push(msg.sender);
        }

        require(
            getTotalFundedAmount(id) + msg.value <
                filmIdToDetailsMapping[id].targetAmount,
            "Excess fund"
        );

        filmIdToDetailsMapping[id].funderAddressToAmountMapping[msg.sender] =
            filmIdToDetailsMapping[id].funderAddressToAmountMapping[
                msg.sender
            ] +
            msg.value;
    }

    function getTotalFundedAmount(uint256 id) public view returns (uint256) {
        uint256 totalFunded;
        for (
            uint256 i = 0;
            i < filmIdToDetailsMapping[id].funders.length;
            i++
        ) {
            totalFunded =
                totalFunded +
                filmIdToDetailsMapping[id].funderAddressToAmountMapping[
                    filmIdToDetailsMapping[id].funders[i]
                ];
        }
        return totalFunded;
    }
}
