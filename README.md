# Agent Bravo Contracts
[Agent Bravo](https://github.com/mikeghen/agent-bravo) is an Agent framework that empowers delegates to operate autonomous AI agents in any GovernorBravo-compatible governance system. Agent Bravo provides the essential functionalities required to allow delegates to participate in governance autonomously via their AI agents.

These contracts include a Compound‑Style **Token**, **Timelock**, and **Governor**, which together help facilitate secure on-chain voting and decision making related to the Agent Bravo framework.

## Agent Bravo Governance System
This is the Agent Bravo Governance System. It is a Compound‑Style Token, Timelock, and Governor, which together help facilitate secure on-chain voting and decision making related to the Agent Bravo framework.

### `AgentBravoToken`

- _Generated through OpenZeppelin's Contract Wizard_
- **Upgradeable:** Built on OpenZeppelin's upgradable contracts using the UUPS proxy pattern.
- **Role-Based Access Control:** Utilizes roles (`MINTER_ROLE`, `PAUSER_ROLE`, and `UPGRADER_ROLE`) to restrict minting, pausing, and upgrading actions.
- **ERC20 Extensions:** Supports token burning (ERC20Burnable), pausing transfers (ERC20Pausable), and flash minting (ERC20FlashMint) for additional utility.
- **Voting & Delegation:** Integrated with ERC20Votes, enabling vote delegation and on-chain governance participation.
- **Gasless Approvals:** Implements ERC20Permit for EIP‑2612 compliant, signature-based approvals.

### `AgentBravoTimelock`

- _Unaudited, AI-generated implementation of the Compound Timelock contract (ICompoundTimelock)_
- **Compound‑style timelock mechanism:** Provides a secure delay for executing governance transactions.
- **Transaction Queueing & Execution:** Allows queuing, executing, and cancellation of transactions after a preset delay.
- **Enforced Delay with Grace Period:** Ensures that transactions are executed only after the minimum delay has elapsed and before the grace period expires.
- **Admin Controls:** Provides administrative functionality for setting delays and handling pending admin transfers.

### `AgentBravoGovernor`
- _Generated through OpenZeppelin's Contract Wizard_
- **Proposal Lifecycle Management:** Supports proposal creation, vote counting, queuing, and execution.
- **Configurable Governance Parameters:** Customizable settings including a voting delay (1 day), voting period (1 week), proposal threshold (10,000 tokens), and a quorum of 4% of the token supply.
- **Timelock Integration:** Ensures that approved proposals are queued and executed through the timelock for enhanced security.
- **Upgradeable Governance:** Leverages a suite of OpenZeppelin Governor modules and supports UUPS upgrades, with upgrades restricted to the contract owner.

