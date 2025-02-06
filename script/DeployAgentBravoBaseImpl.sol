// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.23;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import {AgentBravoToken} from "src/AgentBravoToken.sol";
import {AgentBravoTimelock} from "src/AgentBravoTimelock.sol";
import {AgentBravoGovernor} from "src/AgentBravoGovernor.sol";
import {IVotes} from "@openzeppelin/contracts/governance/utils/IVotes.sol";
import {ICompoundTimelock} from "@openzeppelin/contracts/vendor/compound/ICompoundTimelock.sol";

/**
 * @notice Base deployment script for AgentBravo contracts.
 *
 * This abstract contract deploys (and initializes) the following in order:
 *  - AgentBravo token (with initialize(defaultAdmin, pauser, minter, upgrader))
 *  - AgentBravoTimelock (via its constructor with admin and delay)
 *  - AgentBravoGovernor (with initialize(IVotes token, ICompoundTimelock timelock, initialOwner))
 *
 * To use this deployment script, extend it and implement the three configuration
 * functions: getTokenConfig, getTimelockConfig, and getGovernorConfig.
 */
abstract contract DeployAgentBravoBaseImpl is Script {
    uint256 public deployerPrivateKey;

    struct TokenConfig {
        address defaultAdmin;
        address pauser;
        address minter;
        address upgrader;
    }

    struct TimelockConfig {
        address admin;
        uint256 delay;
    }

    struct GovernorConfig {
        // initialOwner will be used to initialize the governor (see OwnableUpgradeable)
        address initialOwner;
    }

    /// @notice Initializes the deployer private key.
    function setUp() public virtual {
        deployerPrivateKey = vm.envOr(
            "DEPLOYER_PRIVATE_KEY", uint256(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80)
        );
    }

    /// @notice Returns the configuration for initializing the AgentBravo token.
    function getTokenConfig() public virtual returns (TokenConfig memory);

    /// @notice Returns the configuration for deploying the AgentBravoTimelock.
    function getTimelockConfig() public virtual returns (TimelockConfig memory);

    /// @notice Returns the configuration for initializing the AgentBravoGovernor.
    function getGovernorConfig() public virtual returns (GovernorConfig memory);

    /**
     * @notice Deploys and initializes AgentBravo, AgentBravoTimelock and AgentBravoGovernor.
     * @return governor The deployed AgentBravoGovernor contract.
     */
    function run() public virtual returns (AgentBravoGovernor) {
        vm.startBroadcast(deployerPrivateKey);
        console.log("Deploying AgentBravo contracts...");
        console.log("Deployer address:", vm.addr(deployerPrivateKey));

        // --- Deploy AgentBravo token with UUPS proxy ---
        TokenConfig memory tokenConfig = getTokenConfig();
        address proxy = Upgrades.deployUUPSProxy(
            "AgentBravoToken.sol",
            abi.encodeCall(
                AgentBravoToken.initialize,
                (tokenConfig.defaultAdmin, tokenConfig.pauser, tokenConfig.minter, tokenConfig.upgrader)
            )
        );
        AgentBravoToken token = AgentBravoToken(proxy);
        console.log("AgentBravo proxy deployed:", address(proxy));
        console.log("AgentBravo token deployed:", address(token));

        // --- Deploy AgentBravoTimelock ---
        TimelockConfig memory timelockConfig = getTimelockConfig();
        AgentBravoTimelock timelock = new AgentBravoTimelock(timelockConfig.admin, timelockConfig.delay);
        console.log("AgentBravoTimelock deployed to:", address(timelock));

        // --- Deploy AgentBravoGovernor using UUPS proxy ---
        GovernorConfig memory governorConfig = getGovernorConfig();
        address governorProxy = Upgrades.deployUUPSProxy(
            "AgentBravoGovernor.sol",
            abi.encodeCall(
                AgentBravoGovernor.initialize,
                (IVotes(address(token)), ICompoundTimelock(payable(address(timelock))), governorConfig.initialOwner)
            )
        );
        AgentBravoGovernor governor = AgentBravoGovernor(payable(governorProxy));
        console.log("AgentBravoGovernor proxy deployed:", address(governorProxy));
        console.log("AgentBravoGovernor deployed:", address(governor));

        vm.stopBroadcast();

        return governor;
    }
}
