// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract BondERC20 is ERC20 {
    constructor(uint256 initialSupply) ERC20("BondERC20", "BND") {
        _mint(msg.sender, initialSupply);
    }
}

contract RewardERC20 is ERC20 {
    constructor(uint256 initialSupply) ERC20("RewardERC20", "RWD") {
        _mint(msg.sender, initialSupply);
    }
}