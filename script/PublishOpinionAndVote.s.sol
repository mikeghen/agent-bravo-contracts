// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.23;

import "forge-std/Script.sol";
import {AgentBravoDelegate} from "src/AgentBravoDelegate.sol";

contract PublishOpinionAndVote is Script {
    uint256 private deployerPrivateKey;
    
    // Constants for the deployed AgentBravoDelegate contract address and proposal parameters.
    address constant AGENT_BRAVO_DELEGATE_ADDRESS = 0x30353Fb2a10415f9B57fF66F6c9ad6F60Ca5601B;
    uint256 constant PROPOSAL_ID = 92230157430513759835867247218458269678426442886362929087811850712624514825843; // The proposal id you wish to vote on.
    uint8 constant SUPPORT = 1; // Vote type (0 = Against, 1 = For, 2 = Abstain).
    string constant OPINION = "I believe this proposal is beneficial.";
    string constant REASONING = "After reviewing the details, it is a great opportunity to support.";

    /// @notice Loads the deployer's private key from the environment.
    function setUp() public virtual {
        deployerPrivateKey = vm.envOr(
            "DEPLOYER_PRIVATE_KEY", 
            uint256(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80)
        );
    }

    /// @notice Publishes an opinion and casts a vote on a proposal via the AgentBravoDelegate.
    function run() external {
        setUp();

        // Instantiate the AgentBravoDelegate contract using the constant address.
        AgentBravoDelegate delegate = AgentBravoDelegate(AGENT_BRAVO_DELEGATE_ADDRESS);

        // Start broadcasting using the deployer's private key.
        vm.startBroadcast(deployerPrivateKey);
        uint256 voteWeight = delegate.publishOpinionAndVote(PROPOSAL_ID, SUPPORT, OPINION, REASONING);
        vm.stopBroadcast();

        console.log("Published opinion and voted with a weight of:", voteWeight);
    }
} 