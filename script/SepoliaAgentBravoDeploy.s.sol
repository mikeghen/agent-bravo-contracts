// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.23;

import {DeployAgentBravoBase} from "script/DeployAgentBravoBase.sol";
import {AgentBravoGovernor} from "src/AgentBravoGovernor.sol";
import {AgentBravoDelegateFactory} from "src/AgentBravoDelegateFactory.sol";
import {AgentBravoDelegate} from "src/AgentBravoDelegate.sol";

/**
 * @notice Unified deployment script for AgentBravo contracts on Sepolia.
 *
 * Configures and deploys the token, timelock, governor, delegate implementation, delegate factory,
 * and a delegate clone with an initialized voting policy.
 */
contract SepoliaAgentBravoDeploy is DeployAgentBravoBase {
    // Define string constants for the delegate parameters.
    string constant BACKSTORY = "I am a seasoned delegate with experience reviewing governance proposals";
    string constant VOTE_NO_CONDITIONS = "The proposal does not clearly demonstrate a return on investment (ROI) of at least 10% annually.";
    string constant VOTE_YES_CONDITIONS = "The proposal clearly demonstrates a return on investment (ROI) of at least 10% annually.";
    string constant VOTE_ABSTAIN_CONDITIONS = "The proposal's return on investment (ROI) cannot be accurately determined from the provided information.";

    // --- Token Configuration Constants ---
    address constant SEPOLIA_TOKEN_DEFAULT_ADMIN = 0x6A3bD184C067F3e83c0149f4154c0F5bf95dD780;
    address constant SEPOLIA_TOKEN_PAUSER = 0x6A3bD184C067F3e83c0149f4154c0F5bf95dD780;
    address constant SEPOLIA_TOKEN_MINTER = 0x6A3bD184C067F3e83c0149f4154c0F5bf95dD780;
    address constant SEPOLIA_TOKEN_UPGRADER = 0x6A3bD184C067F3e83c0149f4154c0F5bf95dD780;

    // --- Timelock and Governor Configuration Constants ---
    address constant SEPOLIA_TIMELOCK_ADMIN = 0x6A3bD184C067F3e83c0149f4154c0F5bf95dD780;
    address constant SEPOLIA_GOVERNOR_INITIAL_OWNER = 0x6A3bD184C067F3e83c0149f4154c0F5bf95dD780;
    uint256 constant TIMELOCK_DELAY = 2 days;

    // Override token config function:
    function getTokenConfig() public pure override returns (TokenConfig memory) {
        return TokenConfig({
            defaultAdmin: SEPOLIA_TOKEN_DEFAULT_ADMIN,
            pauser: SEPOLIA_TOKEN_PAUSER,
            minter: SEPOLIA_TOKEN_MINTER,
            upgrader: SEPOLIA_TOKEN_UPGRADER
        });
    }

    // Override timelock config function:
    function getTimelockConfig() public pure override returns (TimelockConfig memory) {
        return TimelockConfig({admin: SEPOLIA_TIMELOCK_ADMIN, delay: TIMELOCK_DELAY});
    }

    // Override governor config function:
    function getGovernorConfig() public pure override returns (GovernorConfig memory) {
        return GovernorConfig({initialOwner: SEPOLIA_GOVERNOR_INITIAL_OWNER});
    }

    // Override delegate config function:
    function getDelegateConfig() public view override returns (DelegateConfig memory) {
        return DelegateConfig({
            delegateOwner: vm.addr(deployerPrivateKey),
            backstory: "I am a seasoned delegate with experience reviewing governance proposals",
            voteNoConditions: "The proposal does not clearly demonstrate a return on investment (ROI) of at least 10% annually.",
            voteYesConditions: "The proposal clearly demonstrates a return on investment (ROI) of at least 10% annually.",
            voteAbstainConditions: "The proposal's return on investment (ROI) cannot be accurately determined from the provided information."
        });
    }
}
