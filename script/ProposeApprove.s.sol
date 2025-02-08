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
        address walletToApprove = 0x6A3bD184C067F3e83c0149f4154c0F5bf95dD780;

        // Prepare the proposal details.
        // Our proposal will call token.approve(walletToApprove, 100).
        // Since this is a call on the token contract, we create a single-element array.
        address[] memory targets = new address[](1);
        targets[0] = tokenAddress;

        uint256[] memory values = new uint256[](1);
        values[0] = 100; // No ETH to be sent with approve.

        // Encode the call data for approve(address,uint256)
        bytes[] memory calldatas = new bytes[](1);
        calldatas[0] = abi.encodeWithSignature("approve(address,uint256)", walletToApprove, 100);

        // Description for the proposal.
        string memory description =
            "I propose we allow 0x6A3bD184C067F3e83c0149f4154c0F5bf95dD780 to spend 1000 BRAVO tokens for whatever they want.";

        // Get the governor contract instance.
        AgentBravoGovernor governor = AgentBravoGovernor(payable(governorAddress));

        // Start broadcasting using the deployer_private_key.
        vm.startBroadcast(deployerPrivateKey);
        uint256 proposalId = governor.propose(targets, values, calldatas, description);
        vm.stopBroadcast();

        console.log("Created proposal with ID:", proposalId);
    }
}
