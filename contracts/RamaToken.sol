// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./Films.sol";

contract RamaToken is ERC20, Films, Ownable {
    constructor(uint256 initialSupply) ERC20("Picturama", "RAMA") Films() {
        _mint(address(this), initialSupply);
    }
}
