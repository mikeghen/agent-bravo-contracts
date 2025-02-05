// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.23;

import {DeployAgentBravoBaseImpl} from "script/DeployAgentBravoBaseImpl.sol";
import {AgentBravoGovernor} from "src/AgentBravoGovernor.sol";

/**
 * @notice Deployment script for AgentBravo contracts on Sepolia.
 *
 * This contract configures the token, timelock, and governor contracts
 * using pre-determined constants suitable for the Sepolia testnet.
 *
 */
contract SepoliaAgentBravoDeploy is DeployAgentBravoBaseImpl {
    // --- Token Configuration Constants ---
    // Update these addresses with the intended roles for the AgentBravo token.
    address constant SEPOLIA_TOKEN_DEFAULT_ADMIN = 0x6A3bD184C067F3e83c0149f4154c0F5bf95dD780;
    address constant SEPOLIA_TOKEN_PAUSER = 0x6A3bD184C067F3e83c0149f4154c0F5bf95dD780;
    address constant SEPOLIA_TOKEN_MINTER = 0x6A3bD184C067F3e83c0149f4154c0F5bf95dD780;
    address constant SEPOLIA_TOKEN_UPGRADER = 0x6A3bD184C067F3e83c0149f4154c0F5bf95dD780;
    address constant SEPOLIA_TIMELOCK_ADMIN = 0x6A3bD184C067F3e83c0149f4154c0F5bf95dD780;
    address constant SEPOLIA_GOVERNOR_INITIAL_OWNER = 0x6A3bD184C067F3e83c0149f4154c0F5bf95dD780;

    // --- Timelock Configuration Constant ---
    // Set an appropriate delay for the timelock (e.g., 2 days)
    uint256 constant TIMELOCK_DELAY = 2 days;

    /// @notice Returns the configuration for initializing the AgentBravo token.
    function getTokenConfig() public pure override returns (TokenConfig memory) {
        return TokenConfig({
            defaultAdmin: SEPOLIA_TOKEN_DEFAULT_ADMIN,
            pauser: SEPOLIA_TOKEN_PAUSER,
            minter: SEPOLIA_TOKEN_MINTER,
            upgrader: SEPOLIA_TOKEN_UPGRADER
        });
    }

    /// @notice Returns the configuration for deploying the AgentBravoTimelock.
    function getTimelockConfig() public pure override returns (TimelockConfig memory) {
        // Use the deployer's address as the timelock admin.
        return TimelockConfig({admin: SEPOLIA_TIMELOCK_ADMIN, delay: TIMELOCK_DELAY});
    }

    /// @notice Returns the configuration for initializing the AgentBravoGovernor.
    function getGovernorConfig() public pure override returns (GovernorConfig memory) {
        // Use the deployer's address as the initial owner of the governor.
        return GovernorConfig({initialOwner: SEPOLIA_GOVERNOR_INITIAL_OWNER});
    }

    /// @notice Executes the deployment by invoking the base implementation.
    function run() public override returns (AgentBravoGovernor) {
        return super.run();
    }
}
