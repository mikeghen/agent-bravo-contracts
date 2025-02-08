// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.23;

import {DeployAgentBravoDelegateBaseImpl} from "script/DeployAgentBravoDelegateBaseImpl.sol";
import {AgentBravoDelegateFactory} from "src/AgentBravoDelegateFactory.sol";
import {AgentBravoDelegate} from "src/AgentBravoDelegate.sol";
import {console} from "forge-std/console.sol";

/**
 * @notice Deployment script for AgentBravoDelegate contracts on Sepolia.
 *
 * This contract deploys the delegate implementation, factory, and uses the factory
 * to deploy an initial delegate clone while initializing it with a governor and owner.
 */
contract SepoliaAgentBravoDelegateDeploy is DeployAgentBravoDelegateBaseImpl {
    // --- Delegate Initialization Constants ---
    // In this example the same address is used for the delegate governor and owner.
    // Check README.md for the address of the latest Governor.
    address constant SEPOLIA_DELEGATE_GOVERNOR = 0x0705294b11715FC2C1D231D3616D76fc07F3c8Cd;

    /**
     * @notice Executes the deployment of AgentBravoDelegate contracts on Sepolia.
     * It deploys the implementation, the factory, and then creates a clone via the factory.
     * @return factory The deployed AgentBravoDelegateFactory contract.
     */
    function run() public override returns (AgentBravoDelegateFactory factory) {
        // Deploy the implementation and factory using the base contract
        factory = super.run();

        // Optionally, deploy a delegate clone for the deployer via the factory and initialize it.
        vm.startBroadcast(deployerPrivateKey);
        address clone = factory.deployAgentBravoDelegate(SEPOLIA_DELEGATE_GOVERNOR, vm.addr(deployerPrivateKey));
        console.log("AgentBravoDelegate clone deployed at:", clone);

        // Set the initial voting policy for the delegate clone.
        AgentBravoDelegate(clone).updateVotingPolicy(
            // Backstory
            "I am a seasoned delegate with experience reviewing governance proposals",
            // Vote NO
            "The proposal does not clearly demonstrate a return on investment (ROI) of at least 10% annually.",
            // Vote YES
            "The proposal clearly demonstrates a return on investment (ROI) of at least 10% annually.",
            // Abstain
            "The proposal's return on investment (ROI) cannot be accurately determined from the provided information."
        );

        // Confirm we can read the voting policy by destructuring the tuple.
        (
            string memory backstory,
            string memory voteNoConditions,
            string memory voteYesConditions,
            string memory voteAbstainConditions
        ) = AgentBravoDelegate(clone).votingPolicy();

        console.log("Voting policy backstory:", backstory);
        console.log("Voting policy vote NO conditions:", voteNoConditions);
        console.log("Voting policy vote YES conditions:", voteYesConditions);
        console.log("Voting policy vote ABSTAIN conditions:", voteAbstainConditions);

        vm.stopBroadcast();

        return factory;
    }
}
