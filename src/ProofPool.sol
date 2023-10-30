// SPDX-License-Identifier: MIT
//     _    ___  ____     _    _  _____    _        _    ____ ____  
//    / \  / _ \|  _ \   / \  | |/ |_ _|  | |      / \  | __ / ___| 
//   / _ \| | | | |_) | / _ \ | ' / | |   | |     / _ \ |  _ \___ \ 
//  / ___ | |_| |  _ < / ___ \| . \ | |   | |___ / ___ \| |_) ___) |
// /_/   \_\___/|_| \_/_/   \_|_|\_|___|  |_____/_/   \_|____|____/ 

pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Counters} from "lib/openzeppelin-contracts/contracts/utils/Counters.sol";


// submit task
// submit proof
// read proof data

struct TaskAssignment {
    address prover;
    address feeToken;
    address amount;
    uint64 expiry;
    bytes signature;
}

struct TaskStatus {
    bytes instance;
    bool proven;
}


contract ProofPool {

    using Counters for Counters.Counter;


    address bondToken;
    uint256 bondAmount;
    address verifierAddress;

    Counters.Counter public taskIdCounter;
    mapping(uint256 => TaskStatus) public taskStatus;

    event TaskSubmitted();

    event BondDeposited();

    error INVALID_ASSIGNMENT();
    error INVALID_PROVER_SIG();

    function init(
        address calldata _bondToken,
        uint256 calldata _bondAmount,
        address calldata _verifierAddress
        
    )
        external
    {   
        // only owner
        // init bond type and amout for this task
        // init verifier address
        bondToken = _bondToken;
        bondAmount = _bondAmount;
        verifierAddress = _verifierAddress;
    }


    function submitTask(
        bytes calldata instance,
        // bytes calldata txList,
        TaskAssignment memory assignment
    )
        external
        returns (uint256 taskId)
    {

        // Check prover assignment
        if (
            assignment.expiry <= block.timestamp
        ) {
            revert INVALID_ASSIGNMENT();
        }

        // pay the reward
        IERC20(assignment.feeToken).transferFrom(
            msg.sender,
            assignment.prover,
            assignment.amount
        );

        // deposited bond
        IERC20(bondAddress).transferFrom(
            assignment.prover,
            this,
            bondAmount
        );

        if (!assignment.prover.isContract()) {
            address assignedProver = assignment.prover;

            if (
                _hashAssignment(input, assignment).recover(assignment.data)
                    != assignedProver
            ) {
                revert INVALID_PROVER_SIG();
            }

        } else if (
            assignment.prover.supportsInterface(type(IERC1271).interfaceId)
        ) {
            if (
                IERC1271(assignment.prover).isValidSignature(
                    _hashAssignment(input, assignment), assignment.data
                ) != EIP1271_MAGICVALUE
            ) {
                revert INVALID_PROVER_SIG();
            }

        } else {
            revert INVALID_PROVER();
        }

        taskId = taskIdCounter.current();
        taskStatus[taskId] = TaskStatus({
            instance: instance,
            status: false
        });
        taskIdCounter.increment();


    }

    function submitProof(
        bytes calldata input,
        bytes calldata txList
    )
        external
    {

    }

    function readProofStatus(
        bytes calldata input,
        bytes calldata txList
    )
        external
    {

    }

    function hashAssignmentForTxList(
        TaikoData.ProverAssignment memory assignment,
        bytes32 txListHash
    )
        internal
        pure
        returns (bytes32)
    {
        return keccak256(
            abi.encode(
                "PROVER_ASSIGNMENT",
                txListHash,
                assignment.feeToken,
                assignment.expiry,
                assignment.tierFees
            )
        );
    }

    function _validateAssignment(
        uint16 minTier,
        bytes32 txListHash,
        TaikoData.ProverAssignment memory assignment
    )
        private
        returns (uint256 proverFee)
    {
        // Check assignment not expired
        if (block.timestamp >= assignment.expiry) {
            revert L1_ASSIGNMENT_EXPIRED();
        }

        if (txListHash == 0 || assignment.prover == address(0)) {
            revert L1_ASSIGNMENT_INVALID_PARAMS();
        }

        // Hash the assignment with the txListHash, this hash will be signed by
        // the prover, therefore, we add a string as a prefix.
        bytes32 hash = hashAssignmentForTxList(assignment, txListHash);

        if (!assignment.prover.isValidSignature(hash, assignment.signature)) {
            revert L1_ASSIGNMENT_INVALID_SIG();
        }

        // Find the prover fee using the minimal tier
        proverFee = _getProverFee(assignment.tierFees, minTier);

        // The proposer irrevocably pays a fee to the assigned prover, either in
        // Ether or ERC20 tokens.
        if (assignment.feeToken == address(0)) {
            // Paying Ether
            if (msg.value < proverFee) revert L1_ASSIGNMENT_INSUFFICIENT_FEE();
            assignment.prover.sendEther(proverFee);
            unchecked {
                // Return the extra Ether to the proposer
                uint256 refund = msg.value - proverFee;
                if (refund != 0) msg.sender.sendEther(refund);
            }
        } else {
            // Paying ERC20 tokens
            if (msg.value != 0) msg.sender.sendEther(msg.value);
            ERC20Upgradeable(assignment.feeToken).transferFrom(
                msg.sender, assignment.prover, proverFee
            );
        }
    }

    function _hashAssignment(
        TaikoData.BlockMetadataInput memory input,
        TaikoData.ProverAssignment memory assignment
    )
        private
        view
        returns (bytes32)
    {
        return keccak256(abi.encode(input, msg.value, assignment.expiry));
    }

}