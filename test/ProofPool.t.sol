// // SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
// import {ProverFactory} from "../src/ProverFactory.sol";
// import {Prover} from "../src/Prover.sol";
// import {BlockMetadataInput, ProverAssignment} from "../src/interfaces/IProver.sol";
// import {RegularERC20} from "./RegularERC20.sol";
// import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
// import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import {ERC165Checker} from "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";

import { ProofPool } from "../src/ProofPool.sol";
import { RewardERC20, BondERC20 } from "./SomeERC20.sol";
import { YulDeployer } from "./YulDeployer.sol";
// import "./SomeVerifier.yul";


interface SomeVerifier {}

contract ProofPoolTest is Test {
    uint256 private _seed = 0x12345678;

    function getRandomAddress() internal returns (address) {
        bytes32 randomHash = keccak256(abi.encodePacked("address", _seed++));
        return address(bytes20(randomHash));
    }

    
    // Prover public prover;
    // RegularERC20 public token;

    uint256 internal ownerPrivateKey;
    address internal owner;
    address internal requester;
    address internal prover;
    address internal openProver;

    RewardERC20 rewardToken;
    BondERC20 bondToken;

    ProofPool public proofPool;

    YulDeployer yulDeployer = new YulDeployer();
    SomeVerifier someVerifer;


    // address internal proposer;

    function setUp() public {
        
        ownerPrivateKey = 0xA11CE;
        owner = vm.addr(ownerPrivateKey);

        requester = getRandomAddress();
        prover = getRandomAddress();
        openProver = getRandomAddress();

        rewardToken = new RewardERC20(100 ether);
        bondToken = new BondERC20(100 ether);
        rewardToken.transfer(requester, 50 ether);
        bondToken.transfer(prover, 50 ether);

        console2.log("1");

        someVerifer = SomeVerifier(yulDeployer.deployContract("SomeVerifier"));
        console2.log("someVerifer address:", address(someVerifer));



        // address _owner,
        // address  _bondToken,
        // uint256  _bondAmount,
        // address  _verifierAddress,
        // uint32  _proofWindow,
        // uint8  _instanceLength


        // proofPool = new ProofPool(
        //     owner,
        //     address(bondToken),
        //     10 ether,



        // );
        // prover = Prover(proverFactory.createProver(owner));

        

        // vm.startPrank(proposer);
        // token = new RegularERC20(100 ether);
        // token.approve(address(prover), 10 ether);
        // vm.stopPrank();
    }

    function test_nothing() public {

        // assertEq(1, 1);
    }

}