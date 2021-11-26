// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./Film.sol";

contract Films {
    Film private film;
    bytes32[] private filmIds;

    mapping(bytes32 => Film) private filmIdToFilm;

    function addFilm(
        bytes32 filmId,
        uint256 targetFund,
        address filmOwner
    ) internal {
        filmIdToFilm[filmId] = new Film(targetFund, filmOwner);
        filmIds.push(filmId);
    }

    function getAllFilmIds() internal view returns (bytes32[] memory) {
        return filmIds;
    }

    function fund(
        bytes32 filmId,
        uint256 value,
        address sender
    ) internal returns (bool) {
        if (doesItemExist(filmId)) {
            filmIdToFilm[filmId].fund(value, sender);
            return true;
        } else {
            return false;
        }
    }

    function removeFund(bytes32 filmId, address sender) internal {
        if (doesItemExist(filmId)) {
            filmIdToFilm[filmId].removeFund(sender);
        } else {
            revert("Invalid request");
        }
    }

    function getFilm(bytes32 filmId) internal view returns (Film) {
        if (!doesItemExist(filmId)) {
            revert("Film does not exist");
        }
        return filmIdToFilm[filmId];
    }

    function doesItemExist(bytes32 filmId) internal view returns (bool) {
        for (uint256 i = 0; i < filmIds.length; i++) {
            if (filmIds[i] == filmId) {
                return true;
            }
        }
        return false;
    }

    function getFundOfUser(bytes32 filmId, address sender)
        internal
        view
        returns (Film.UserFundDetails memory)
    {
        if (doesItemExist(filmId)) {
            return filmIdToFilm[filmId].getFundOfUser(sender);
        } else {
            revert("Invalid request");
        }
    }

    function getFilmFundDetails(bytes32 filmId)
        internal
        view
        returns (Film.FilmFundDetails memory)
    {
        if (doesItemExist(filmId)) {
            return filmIdToFilm[filmId].getFilmFundDetails();
        } else {
            revert("Invalid request");
        }
    }

    function getFunds(bytes32 filmId) public view returns (Film.Fund[] memory) {
        if (doesItemExist(filmId)) {
            return filmIdToFilm[filmId].getFunds();
        } else {
            revert("Invalid request");
        }
    }

    function getClaimableBalance(bytes32 filmId, address sender)
        public
        view
        returns (uint256)
    {
        if (doesItemExist(filmId)) {
            return filmIdToFilm[filmId].calculateYieldTotal(sender);
        } else {
            revert("Invalid request");
        }
    }
}
