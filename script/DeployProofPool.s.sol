// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import { RewardERC20, BondERC20 } from "../test/SomeERC20.sol";
import { YulDeployer } from "../test/YulDeployer.sol";
import { ProofPool } from "../src/ProofPool.sol";

interface SomeVerifier {}

contract DeployProofPool is Script {

    uint256 public deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    uint256 public requesterPrivateKey = vm.envUint("PRIVATE_KEY1");
    uint256 public proverPrivateKey = vm.envUint("PRIVATE_KEY2");

    address public deployer = vm.addr(deployerPrivateKey);
    address public requester = vm.addr(requesterPrivateKey);
    address public prover = vm.addr(proverPrivateKey);

    RewardERC20 rewardToken;
    BondERC20 bondToken;

    ProofPool public proofPool;

    YulDeployer yulDeployer = new YulDeployer();
    SomeVerifier someVerifer;

    function setUp() public {}

    function run() public {
        vm.startBroadcast(deployerPrivateKey);
        RewardERC20 rewardToken = new RewardERC20(100 ether);
        BondERC20 bondToken = new BondERC20(100 ether);
        rewardToken.transfer(requester, 50 ether);
        bondToken.transfer(prover, 50 ether);

        someVerifer = SomeVerifier(yulDeployer.deployContract("SomeVerifier"));
        console2.log("someVerifer's address:", address(someVerifer));

        proofPool = new ProofPool(
            deployer,
            address(bondToken),
            10 ether,
            address(someVerifer),
            3600,
            32
        );

        vm.broadcast();
    }
}
