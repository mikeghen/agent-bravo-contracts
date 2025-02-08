// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.23;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";

// Import contract dependencies
import {AgentBravoToken} from "src/AgentBravoToken.sol";
import {AgentBravoTimelock} from "src/AgentBravoTimelock.sol";
import {AgentBravoGovernor} from "src/AgentBravoGovernor.sol";
import {IVotes} from "@openzeppelin/contracts/governance/utils/IVotes.sol";
import {ICompoundTimelock} from "@openzeppelin/contracts/vendor/compound/ICompoundTimelock.sol";
import {AgentBravoDelegate} from "src/AgentBravoDelegate.sol";
import {AgentBravoDelegateFactory} from "src/AgentBravoDelegateFactory.sol";

/**
 * @notice Unified base deployment script for Agent Bravo contracts.
 * Deploys Token, Timelock, Governor, Delegate implementation & factory and a Delegate clone.
 */
abstract contract DeployAgentBravoBase is Script {
    uint256 public deployerPrivateKey;

    // Config structs for token, timelock and governor
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
        address initialOwner;
    }

    // Delegate configuration struct
    struct DelegateConfig {
        address delegateGovernor;
        address delegateOwner;
        string backstory;
        string voteNoConditions;
        string voteYesConditions;
        string voteAbstainConditions;
    }

    /**
     * @notice Initializes the deployer private key.
     */
    function setUp() public virtual {
        deployerPrivateKey = vm.envOr(
            "DEPLOYER_PRIVATE_KEY",
            uint256(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80)
        );
    }

    /// @notice Returns configuration for AgentBravo token initialization.
    function getTokenConfig() public virtual returns (TokenConfig memory);

    /// @notice Returns configuration for deploying the AgentBravoTimelock.
    function getTimelockConfig() public virtual returns (TimelockConfig memory);

    /// @notice Returns configuration for initializing the AgentBravoGovernor.
    function getGovernorConfig() public virtual returns (GovernorConfig memory);

    /// @notice Returns configuration for deploying the AgentBravoDelegate clone.
    function getDelegateConfig() public virtual returns (DelegateConfig memory);

    /**
     * @notice Deploys AgentBravo contracts:
     *         - AgentBravoToken (via UUPS proxy)
     *         - AgentBravoTimelock
     *         - AgentBravoGovernor (via UUPS proxy)
     *         - AgentBravoDelegate implementation, factory and delegate clone
     *         - Initializes the delegate voting policy.
     * @return governor The deployed AgentBravoGovernor contract.
     * @return delegateFactory The deployed AgentBravoDelegateFactory contract.
     * @return delegateClone The deployed and initialized AgentBravoDelegate clone.
     */
    function run() public virtual returns (
        AgentBravoGovernor governor,
        AgentBravoDelegateFactory delegateFactory,
        AgentBravoDelegate delegateClone
    ) {
        setUp();
        vm.startBroadcast(deployerPrivateKey);
        console.log("Deploying Agent Bravo contracts...");
        console.log("Deployer address:", vm.addr(deployerPrivateKey));

        AgentBravoToken token;
        AgentBravoTimelock timelock;

        { // Deploy AgentBravo token with UUPS proxy
            TokenConfig memory tokenConfig = getTokenConfig();
            address tokenProxy = Upgrades.deployUUPSProxy(
                "AgentBravoToken.sol",
                abi.encodeCall(
                    AgentBravoToken.initialize,
                    (tokenConfig.defaultAdmin, tokenConfig.pauser, tokenConfig.minter, tokenConfig.upgrader)
                )
            );
            token = AgentBravoToken(tokenProxy);
            console.log("AgentBravo Token proxy deployed:", tokenProxy);
            console.log("AgentBravo Token deployed:", address(token));
        }

        { // Deploy AgentBravoTimelock
            TimelockConfig memory timelockConfig = getTimelockConfig();
            timelock = new AgentBravoTimelock(timelockConfig.admin, timelockConfig.delay);
            console.log("AgentBravoTimelock deployed to:", address(timelock));
        }

        { // Deploy AgentBravoGovernor using UUPS proxy
            GovernorConfig memory governorConfig = getGovernorConfig();
            address governorProxy = Upgrades.deployUUPSProxy(
                "AgentBravoGovernor.sol",
                abi.encodeCall(
                    AgentBravoGovernor.initialize,
                    (IVotes(address(token)), ICompoundTimelock(payable(address(timelock))), governorConfig.initialOwner)
                )
            );
            governor = AgentBravoGovernor(payable(governorProxy));
            console.log("AgentBravoGovernor proxy deployed:", governorProxy);
            console.log("AgentBravoGovernor deployed:", address(governor));
        }

        { // Deploy AgentBravoDelegate implementation & factory
            AgentBravoDelegate delegateImpl = new AgentBravoDelegate();
            console.log("AgentBravoDelegate implementation deployed at:", address(delegateImpl));

            delegateFactory = new AgentBravoDelegateFactory(address(delegateImpl));
            console.log("AgentBravoDelegateFactory deployed at:", address(delegateFactory));
        }

        address cloneAddr;
        { // Deploy AgentBravoDelegate clone and update voting policy
            DelegateConfig memory delegateConfig = getDelegateConfig();
            cloneAddr = delegateFactory.deployAgentBravoDelegate(delegateConfig.delegateGovernor, delegateConfig.delegateOwner);
            console.log("AgentBravoDelegate clone deployed at:", cloneAddr);

            AgentBravoDelegate(cloneAddr).updateVotingPolicy(
                delegateConfig.backstory,
                delegateConfig.voteNoConditions,
                delegateConfig.voteYesConditions,
                delegateConfig.voteAbstainConditions
            );
        }

        { // Confirm and log the voting policy update
            (string memory backstory, string memory voteNo, string memory voteYes, string memory voteAbstain) = AgentBravoDelegate(cloneAddr).votingPolicy();
            console.log("Voting Policy:");
            console.log("Backstory:", backstory);
            console.log("Vote NO conditions:", voteNo);
            console.log("Vote YES conditions:", voteYes);
            console.log("Vote ABSTAIN conditions:", voteAbstain);
        }

        vm.stopBroadcast();

        delegateClone = AgentBravoDelegate(payable(cloneAddr));
        return (governor, delegateFactory, delegateClone);
    }
} 