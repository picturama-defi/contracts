// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./Film.sol";
import "./Films.sol";
import "./RamaToken.sol";

contract RamaContract is Films, Ownable {
    ERC20 private ramaToken;

    constructor(address tokenAddress) Films() {
        ramaToken = RamaToken(tokenAddress);
    }

    function addProject(
        bytes32 filmId,
        uint256 targetFund,
        address filmOwner
    ) public payable onlyOwner {
        addFilm(filmId, targetFund, filmOwner);
    }

    function getAllProjectIds() public view returns (bytes32[] memory) {
        return getAllFilmIds();
    }

    function fundProject(bytes32 filmId) public payable {
        bool isSuccessfullyFunded = fund(filmId, msg.value, msg.sender);
        if (isSuccessfullyFunded) {
            ramaToken.transfer(msg.sender, msg.value);
        } else {
            revert("Unable to fund");
        }
    }

    function getProjectById(bytes32 filmId) public view returns (Film) {
        return getFilm(filmId);
    }
}
