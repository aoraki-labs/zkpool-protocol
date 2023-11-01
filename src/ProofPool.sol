// SPDX-License-Identifier: MIT
//     _    ___  ____     _    _  _____    _        _    ____ ____  
//    / \  / _ \|  _ \   / \  | |/ |_ _|  | |      / \  | __ / ___| 
//   / _ \| | | | |_) | / _ \ | ' / | |   | |     / _ \ |  _ \___ \ 
//  / ___ | |_| |  _ < / ___ \| . \ | |   | |___ / ___ \| |_) ___) |
// /_/   \_\___/|_| \_/_/   \_|_|\_|___|  |_____/_/   \_|____|____/ 

pragma solidity ^0.8.20;

import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import { IERC1271 } from "@openzeppelin/contracts/interfaces/IERC1271.sol";
import { IERC165 } 
    from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ReentrancyGuard } 
    from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import { LibBytesUtils } from "./libs/LibBytesUtils.sol";


struct TaskAssignment {
    address prover;
    address feeToken;
    uint256 amount;
    uint64 expiry;
    bytes signature;
}

struct TaskStatus {
    bytes instance;
    address prover;
    uint64 submittedAt;
    bool proven;
}

contract ProofPool is Ownable, ReentrancyGuard {

    using ECDSA for bytes32;

    bytes4 internal constant EIP1271_MAGICVALUE = 0x1626ba7e;

    address bondToken;
    uint256 bondAmount;
    address verifierAddress;
    // The maximum time window allowed for a proof submission (in seconds).
    uint32 proofWindow;
    // The length of instance (in bytes).
    uint8 instanceLength;

    mapping(bytes32 => TaskStatus) public taskStatusMap;

    event TaskSubmitted(
        address indexed requester,
        address indexed prover,
        bytes32 taskKey,
        address token,
        uint256 amount
    );

    event TaskProven(
        address indexed prover,
        bytes32 taskKey
    );

    event BondDeposited(
        address indexed from,
        bytes32 taskKey,
        uint256 amount
    );

    event BondReleased(
        address indexed to,
        bytes32 taskKey,
        uint256 amount
    );

    error INVALID_ASSIGNMENT();
    error INVALID_PROVER();
    error INVALID_PROVER_SIG();
    error TASK_ALREADY_SUBMITTED();
    error TASK_ALREADY_PROVEN();
    error TASK_NONE_EXIST();
    error TASK_NOT_THE_SAME();
    error INVALID_PROOF();
    error TASK_NOT_OPEN();
    error TASK_ALREADY_OPEN();

    constructor(
        address _owner,
        address  _bondToken,
        uint256  _bondAmount,
        address  _verifierAddress,
        uint32  _proofWindow,
        uint8  _instanceLength
    )
        Ownable(_owner) 
    {
        bondToken = _bondToken;
        bondAmount = _bondAmount;
        verifierAddress = _verifierAddress;
        proofWindow = _proofWindow;
        instanceLength = _instanceLength;
    }


    function updateConfig(
        address  _bondToken,
        uint256  _bondAmount,
        address  _verifierAddress,
        uint32  _proofWindow,
        uint8  _instanceLength
    )
        external
        onlyOwner
    {   
        bondToken = _bondToken;
        bondAmount = _bondAmount;
        verifierAddress = _verifierAddress;
        proofWindow = _proofWindow;
        instanceLength = _instanceLength;
    }


    function submitTask(
        bytes calldata instance,
        // bytes calldata txList,
        TaskAssignment memory assignment
    )
        external
        nonReentrant
        returns (bytes32 taskKey)
    {

        // Check prover assignment
        if (assignment.expiry <= block.timestamp) {
            revert INVALID_ASSIGNMENT();
        }

        // Check task already submitted
        taskKey = keccak256(instance);
        if (taskStatusMap[taskKey].prover != address(0)) {
            revert TASK_ALREADY_SUBMITTED();
        }

        // Pay the reward
        IERC20(assignment.feeToken).transferFrom(
            msg.sender,
            assignment.prover,
            assignment.amount
        );

        // Deposit the bond
        IERC20(bondToken).transferFrom(
            assignment.prover,
            address(this),
            bondAmount
        );

        emit BondDeposited(
            assignment.prover,
            taskKey,
            bondAmount
        );

        // Check the signature
        if (!_isContract(assignment.prover)) {
            address assignedProver = assignment.prover;

            if (
                _hashAssignment(
                    instance,
                    assignment
                ).recover(assignment.signature) != assignedProver
            ) {
                revert INVALID_PROVER_SIG();
            }

        } else if (
            IERC165(
                assignment.prover
            ).supportsInterface(type(IERC1271).interfaceId)
        ) {
            if (
                IERC1271(assignment.prover).isValidSignature(
                    _hashAssignment(instance, assignment), assignment.signature
                ) != EIP1271_MAGICVALUE
            ) {
                revert INVALID_PROVER_SIG();
            }

        } else {
            revert INVALID_PROVER();
        }

        // Save the task status
        taskStatusMap[taskKey] = TaskStatus({
            instance: instance,
            prover: assignment.prover,
            submittedAt: uint64(block.timestamp),
            proven: false
        });

        emit TaskSubmitted(
            msg.sender,
            assignment.prover,
            taskKey,
            assignment.feeToken,
            assignment.amount
        );
    
    }

    function proveTask(
        bytes32 taskKey,
        bytes calldata proof
    )
        external
        nonReentrant
    {  
        TaskStatus storage taskStatus = taskStatusMap[taskKey];
        if (taskStatus.prover == address(0) && taskStatus.submittedAt == 0) {
            revert TASK_NONE_EXIST();
        }

        if (
            !LibBytesUtils.equal(
                taskStatus.instance,
                LibBytesUtils.slice(proof, 0, instanceLength)
            )
        ) {
            revert TASK_NOT_THE_SAME();
        }

        if (
            taskStatus.submittedAt + proofWindow <= block.timestamp 
                && taskStatus.prover != msg.sender
        ) {
            revert TASK_NOT_OPEN();
        } else if (
            taskStatus.submittedAt + proofWindow > block.timestamp
                && taskStatus.prover == msg.sender
        ) {
            revert TASK_ALREADY_OPEN();
        }

        (bool _isCallSuccess, ) = verifierAddress.staticcall(proof);
        if (!_isCallSuccess) {
            revert INVALID_PROOF();
        }

        // Update status
        taskStatus.proven = true;

        // Release the bond
        IERC20(bondToken).transfer(
            msg.sender,
            bondAmount
        );

        emit BondReleased(
            msg.sender,
            taskKey,
            bondAmount
        );

        emit TaskProven(
            msg.sender,
            taskKey
        );
        
    }

    function readProofStatus(
        bytes32 taskKey
    )
        external
        view
        returns (TaskStatus memory taskStatus)
    {
        taskStatus = taskStatusMap[taskKey];
        if (taskStatus.prover == address(0) && taskStatus.submittedAt == 0) {
            revert TASK_NONE_EXIST();
        }
    }

    function _isContract(address _addr) 
        private
        view
        returns (bool isContract)
    {
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }

        return (size > 0);
    }

    function _hashAssignment(
        bytes memory _instance,
        TaskAssignment memory _assignment
    )
        private
        pure
        returns (bytes32)
    {
        return keccak256(
            abi.encode(
                _instance,
                _assignment.feeToken,
                _assignment.amount,
                _assignment.expiry
            )
        );
    }

}