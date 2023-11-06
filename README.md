## ProofPool Contract

In the past period, zkpool has collaborated with numerous zk projects. We have combined our previous experiences to design a comprehensive and universal zk interaction workflow that considers decentralization, cost-effectiveness, and efficiency. The purpose of this workflow is to assist our partners in maximizing the utilization of zk capabilities.

### Interaction Flow

Let's imagine that our partner's project has integrated zk tech and wants to utilize zkpool's computational power while interacting with the blockchain. There are five roles involved:

- Partner: Can be a DAO or a team.
- Partner's project contract.
- Users of the partner's project: Requesters of proofs.
- zkpool verifiers.
- zkpool smart contract.

Here is a proposed general process:

1. The partner deploys their own zkpool smart contract, customized with configurations such as window periods, bond amounts, function endpoints, etc. Deployment can be done using a factory contract or by forking our code and deploying it directly.
2. A user (requester) from the partner's project needs to generate a proof. They communicate with zkpool off-chain through a standard interface, negotiate task A, and obtain a signature including the corresponding task details, reward, and deadline. The signature stands for the responsibility for task fulfillment.
3. The requester publishes the task and the signature to the zkpool contract. At this stage, the prover is required to stake a bond and a liability. The prover immediately receives the reward for the proof task ahead of time.
4. Within the specified time frame, the prover submits the proof to the zkpool contract. The zkpool contract verifies if the proof's public input matches the task requirements. It then invokes the function endpoint of the partner's smart contract. If the function execution is successful, the zkpool contract updates the task status to "done" and the prover retrieves their bond.
5. If the proof is not submitted within the proof window, the proof task transitions to the "open" state, allowing anyone else to submit the proof and claim the bond as a reward.
6. If the proof is not submitted within the liability window, the requester can claim all liabilities through the zkpool contract.

There are two types of windows:

Proof Window: During this period, the prover is expected to submit the proof. Failure to do so within the proof window will result in a penalty, leading to the forfeiture of their bond.

Liability Window: This window represents the timeframe within which the task must be completed, and the proof must be submitted. If the proof is not submitted within the liability window, the prover will face a penalty in the form of a liability.

As these two windows serve similar purposes, we will provide configuration options that allow our partners to choose their preferred settings flexibly.

The flowchart is as follows:

![](https://raw.githubusercontent.com/hatark/hosted_files/main/zkpool-flowchat.png)


### Interface specification

Off-chain interface for negotiation between the requester and prover:

**method**: GET /api/signature

**request header**: Content-Type: application/json

**request body**:

```javascript
// Requester initiates the request to the prover, providing necessary information in the request body
instance:           string // Public input of the proof task's circuit, including the transaction hash and rollup ID for an Orbiter
liabilityWindow:    number // The time duration within which the task must be completed after submission. Otherwise, a liability penalty will be imposed, measured in seconds
liabilityToken:     string // The ERC20 address of the liability token
liability:          number // The amount of liability
rewardToken:        string // The ERC20 address of the reward token
reward:             number // The amount of reward
```

**response body example**:

```json
// Result returned by the prover
{
    "prover": "0x97C7FC642a55aE6465f632E81ee127aDa160734B",
    "instance": "0x204ab24c641d07d84c2e509b526ee17d0168360b72d0ff17524d7576c03c4c6d077c0b602ec0b039fc9cb66f505e3cb23e962764a2ec202f30abd9d6ad1c7ab8",
    "rewardToken": "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2", // Address of the reward token for the proof, ERC20 token address, or WETH if it is ETH
    "reward": 250000000000000, // Amount of reward for the proof
    "liabilityToken": "0x8189Ace309dD2247c5B913Ce3C6A78a23F8FA665", // Address of the liability token, ERC20 token address, or WETH if it is ETH
    "liability": 100000000000000000000000000, // Amount of liability reward
    "expiry": 3255997, // The block number before which the signature is available.
    "deadlineWindow": 200, // The timeframe within which the proof task needs to be completed after submission, measured in seconds
    "signature": "0xd241c9dee624c70c303ef5540fdfe7a90cd4b44bf84eeb0a91b5ab00958e2daf" // The prover's signature of keccak256(abi.encode(instance, rewardToken, reward, liabilityToken, liability, expiry, deadlineWindow)).
}
```


### Integration for Partners

We will create a comprehensive demo to showcase the entire process and assist our partners in utilizing zkpool's services more effectively. Stay tuned!
