// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.23;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {AgentBravoDelegate} from "src/AgentBravoDelegate.sol";
import {AgentBravoDelegateFactory} from "src/AgentBravoDelegateFactory.sol";

/**
 * @notice Base deployment script for AgentBravoDelegate and AgentBravoDelegateFactory contracts.
 *
 * This abstract contract deploys:
 *  - AgentBravoDelegate implementation (which remains uninitialized)
 *  - AgentBravoDelegateFactory which will be used to deploy minimal proxy clones of AgentBravoDelegate.
 *
 * Extend this contract (or use it directly) to deploy on your desired network.
 */
abstract contract DeployAgentBravoDelegateBaseImpl is Script {
    uint256 public deployerPrivateKey;

    /**
     * @notice Sets up the deployer private key.
     */
    function setUp() public virtual {
        deployerPrivateKey = vm.envOr(
            "DEPLOYER_PRIVATE_KEY", uint256(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80)
        );
    }

    /**
     * @notice Deploys the AgentBravoDelegate implementation and the AgentBravoDelegateFactory.
     * @return factory The deployed AgentBravoDelegateFactory contract.
     */
    function run() public virtual returns (AgentBravoDelegateFactory factory) {
        setUp();
        vm.startBroadcast(deployerPrivateKey);
        console.log("Deploying AgentBravo Delegate contracts...");
        console.log("Deployer address:", vm.addr(deployerPrivateKey));

        // Deploy AgentBravoDelegate (implementation contract)
        AgentBravoDelegate delegateImpl = new AgentBravoDelegate();
        console.log("AgentBravoDelegate implementation deployed at:", address(delegateImpl));

        // Deploy AgentBravoDelegateFactory with the implementation address
        factory = new AgentBravoDelegateFactory(address(delegateImpl));
        console.log("AgentBravoDelegateFactory deployed at:", address(factory));

        vm.stopBroadcast();
        return factory;
    }
}
