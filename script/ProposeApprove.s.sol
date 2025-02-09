// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.23;

import "forge-std/Script.sol";
import {AgentBravoGovernor} from "src/AgentBravoGovernor.sol";

contract ProposeApprove is Script {
    uint256 private deployerPrivateKey;

    /// @notice Loads the deployer's private key from the environment.
    function setUp() public virtual {
        deployerPrivateKey = vm.envOr(
            "DEPLOYER_PRIVATE_KEY", uint256(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80)
        );
    }

    /// @notice Proposes a transaction to approve a wallet to spend tokens.
    function run() external {
        setUp();

        // Set the target addresses.
        address tokenAddress = 0xCC47c3FF24f44fdE08FdAaAD6cABcf0339295cD2;
        address governorAddress = 0x9c5D85d2A24C2059C46950548c937f0a392849Ce;
        // The wallet we want to approve to spend our tokens.
        address walletToApprove = 0x095a32B4342B38C36E1FD914e1850b5dF1068266;

        // Prepare the proposal details.
        // TODO: Hardcoding this for the purposes of the hackathon.
        // Our proposal will call token.approve(walletToApprove, 100).
        // Since this is a call on the token contract, we create a single-element array.
        address[] memory targets = new address[](1);
        targets[0] = tokenAddress;

        uint256[] memory values = new uint256[](1);
        values[0] = 0; // No ETH to be sent with approve.

        // Encode the call data for approve(address,uint256)
        bytes[] memory calldatas = new bytes[](1);
        calldatas[0] = abi.encodeWithSignature("approve(address,uint256)", walletToApprove, 3);

        // Description for the proposal.
        string memory description =
            "I propose that we spend 1000 BRAVO on a developer hackathon and give away the 1000 BRAVO to the top 10% of developers that use the Agent Bravo Framework to create the best applications.";
        // "I propose we spend 1000 Bravo hosting a happy hour for venture capitalists and other crypto enthusiasts.";
        // "I propose that 1000 BRAVO be sent to the developer that creates any application that is great and will lead to a BIG WIN for the Agent Bravo community. We'll see this 1000 BRAVO come back 5x in no time at all!";

        // Get the governor contract instance.
        AgentBravoGovernor governor = AgentBravoGovernor(payable(governorAddress));

        // Start broadcasting using the deployer_private_key.
        vm.startBroadcast(deployerPrivateKey);
        uint256 proposalId = governor.propose(targets, values, calldatas, description);
        vm.stopBroadcast();

        console.log("Created proposal with ID:", proposalId);
    }
}
