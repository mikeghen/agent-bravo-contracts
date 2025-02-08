# Agent Bravo Contracts
[Agent Bravo](https://github.com/mikeghen/agent-bravo) is an Agent framework that empowers delegates to operate autonomous AI agents in any GovernorBravo-compatible governance system. Agent Bravo provides the essential functionalities required to allow delegates to participate in governance autonomously via their AI agents.

These contracts include a Compound‑Style **Token**, **Timelock**, and **Governor**, which together help facilitate secure on-chain voting and decision making related to the Agent Bravo framework.

## Agent Bravo Governance System 
This is the Agent Bravo Governance System. It is a Compound‑Style [`AgentBravoToken`](src/AgentBravoToken.sol), [`AgentBravoTimelock`](src/AgentBravoTimelock.sol), and [`AgentBravoGovernor`](src/AgentBravoGovernor.sol), which together help facilitate secure on-chain voting and decision making related to the Agent Bravo framework. AI Delegate Agents are created by the [`AgentBravoDelegateFactory`](src/AgentBravoDelegateFactory.sol). After creating an [`AgentBravoDelegate`](src/AgentBravoDelegate.sol) contract, the owner runs the [mikeghen/agent-bravo](https://github.com/mikeghen/agent-bravo) application to start the delegate agent.

### [`AgentBravoDelegate`](src/AgentBravoDelegate.sol)
- **Purpose:** Acts as the dedicated delegation contract for the [Agent Bravo Crew](https://github.com/mikeghen/agent-bravo) to publish their opinions and to vote on governance proposals onchain.
- **Onchain Opinion Publishing:** Enables Agent Bravo to publish its opinions and accompanying reasoning directly on-chain.
- **Proposal Association:** Automatically links each published opinion to a corresponding governance proposal, ensuring proper context and traceability.
- **Onchain Voting & Proposing:** Facilitates governance actions by invoking the `vote` and `propose` methods on target governance projects (e.g., `AgentBravoGovernor` and `CompoundGovernor`), thereby aligning agent operations with on-chain decisions.
- Modeled on [mikeghen/COMPensator](https://github.com/mikeghen/COMPensator)

### [`AgentBravoDelegateFactory`](src/AgentBravoDelegateFactory.sol)
- **Purpose:** Acts as the factory contract for the `AgentBravoDelegate` contract.
- **Delegate Creation:** Enables the creation of `AgentBravoDelegate` instances for the [Agent Bravo Crew](https://github.com/mikeghen/agent-bravo).

### [`AgentBravoToken`](src/AgentBravoToken.sol)

- _Generated through OpenZeppelin's Contract Wizard_
- **Upgradeable:** Built on OpenZeppelin's upgradable contracts using the UUPS proxy pattern.
- **Role-Based Access Control:** Utilizes roles (`MINTER_ROLE`, `PAUSER_ROLE`, and `UPGRADER_ROLE`) to restrict minting, pausing, and upgrading actions.
- **ERC20 Extensions:** Supports token burning (ERC20Burnable), pausing transfers (ERC20Pausable), and flash minting (ERC20FlashMint) for additional utility.
- **Voting & Delegation:** Integrated with ERC20Votes, enabling vote delegation and on-chain governance participation.
- **Gasless Approvals:** Implements ERC20Permit for EIP‑2612 compliant, signature-based approvals.

### [`AgentBravoTimelock`](src/AgentBravoTimelock.sol)

- _Unaudited, AI-generated implementation of the Compound Timelock contract (ICompoundTimelock)_
- **Compound‑style timelock mechanism:** Provides a secure delay for executing governance transactions.
- **Transaction Queueing & Execution:** Allows queuing, executing, and cancellation of transactions after a preset delay.
- **Enforced Delay with Grace Period:** Ensures that transactions are executed only after the minimum delay has elapsed and before the grace period expires.
- **Admin Controls:** Provides administrative functionality for setting delays and handling pending admin transfers.

### [`AgentBravoGovernor`](src/AgentBravoGovernor.sol)
- _Generated through OpenZeppelin's Contract Wizard_
- **Proposal Lifecycle Management:** Supports proposal creation, vote counting, queuing, and execution.
- **Configurable Governance Parameters:** Customizable settings including a voting delay (1 day), voting period (1 week), proposal threshold (10,000 tokens), and a quorum of 4% of the token supply.
- **Timelock Integration:** Ensures that approved proposals are queued and executed through the timelock for enhanced security.
- **Upgradeable Governance:** Leverages a suite of OpenZeppelin Governor modules and supports UUPS upgrades, with upgrades restricted to the contract owner.

## Deployment Addresses

### Arbitrum Sepolia

#### Agent Bravo Delegate Factory
| Contract | Address |
| --- | --- |
| `AgentBravoDelegateFactory` | [0xFFfc8c88B0D0172FdaBb72178E2F8B7DfaA51E68](https://sepolia.arbiscan.io/address/0xFFfc8c88B0D0172FdaBb72178E2F8B7DfaA51E68) |
| `AgentBravoDelegate (Implementation)` | [0xBB468CDb61D17e050E816BdeB38d86f5e41be436](https://sepolia.arbiscan.io/address/0xBB468CDb61D17e050E816BdeB38d86f5e41be436) |
| `AgentBravoDelegate (First Clone)` | [0xE83744A950e1F8BE583727C90b590B659144a2Ac](https://sepolia.arbiscan.io/address/0xE83744A950e1F8BE583727C90b590B659144a2Ac) |

#### Agent Bravo Governance System
| Contract | Address |
| --- | --- |
| `AgentBravoToken` | [0xCC47c3FF24f44fdE08FdAaAD6cABcf0339295cD2](https://sepolia.arbiscan.io/address/0xCC47c3FF24f44fdE08FdAaAD6cABcf0339295cD2) |
| `AgentBravoTimelock` | [0x5e737D373D9Fd592F2d1aeC228bBD08bE198732e](https://sepolia.arbiscan.io/address/0x5e737D373D9Fd592F2d1aeC228bBD08bE198732e) |
| `AgentBravoGovernor` | [0x9c5D85d2A24C2059C46950548c937f0a392849Ce](https://sepolia.arbiscan.io/address/0x9c5D85d2A24C2059C46950548c937f0a392849Ce) |


### Ethereum Sepolia

#### Agent Bravo Delegate Factory
| Contract | Address |
| --- | --- |
| `AgentBravoDelegateFactory` | [0x7c41063Bda9D7B2C67e655179205f074f27E11c1](https://sepolia.etherscan.io/address/0x7c41063Bda9D7B2C67e655179205f074f27E11c1) |
| `AgentBravoDelegate (Implementation)` | [0xd4Df8472c3afCBfA266dEfDDfb3B865Dd44E462a](https://sepolia.etherscan.io/address/0xd4Df8472c3afCBfA266dEfDDfb3B865Dd44E462a) |
| `AgentBravoDelegate (First Clone)` | [0x30353Fb2a10415f9B57fF66F6c9ad6F60Ca5601B](https://sepolia.etherscan.io/address/0x30353Fb2a10415f9B57fF66F6c9ad6F60Ca5601B) |

#### Agent Bravo Governance System
| Contract | Address |
| --- | --- |
| `AgentBravoToken` | [0x0Bb81307daEBB2Ca0A19a44c65717A3728324745](https://sepolia.etherscan.io/address/0x0Bb81307daEBB2Ca0A19a44c65717A3728324745) |
| `AgentBravoTimelock` | [0x9B7282678FEaBA6cBCE7425B1BdE4f4F29521B77](https://sepolia.etherscan.io/address/0x9B7282678FEaBA6cBCE7425B1BdE4f4F29521B77) |
| `AgentBravoGovernor` | [0x0705294b11715FC2C1D231D3616D76fc07F3c8Cd](https://sepolia.etherscan.io/address/0x0705294b11715FC2C1D231D3616D76fc07F3c8Cd) |
