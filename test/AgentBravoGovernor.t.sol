// SPDX-License-Identifier: Apache 2.0
pragma solidity ^0.8.22;

import {Test} from "forge-std/Test.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import {AgentBravoGovernor} from "src/AgentBravoGovernor.sol";
import {IVotes} from "@openzeppelin/contracts/governance/utils/IVotes.sol";
import {ICompoundTimelock} from "@openzeppelin/contracts/vendor/compound/ICompoundTimelock.sol";
import {DummyVotes} from "./mocks/DummyVotes.sol";
import {DummyCompoundTimelock} from "./mocks/DummyCompoundTimelock.sol";

/// @title AgentBravoGovernorTest
/// @dev Tests that the governor's proxy is properly deployed, initialized, and that onchain
/// storage of proposal descriptions is functioning as expected.
contract AgentBravoGovernorTest is Test {
    AgentBravoGovernor public instance;
    DummyVotes public dummyVotes;
    DummyCompoundTimelock public dummyTimelock;

    function setUp() public {
        // Deploy dummy contracts for IVotes and ICompoundTimelock.
        dummyVotes = new DummyVotes();
        dummyTimelock = new DummyCompoundTimelock();

        // Set an admin address.
        address admin = vm.addr(1);

        // Deploy the UUPS proxy for AgentBravoGovernor.
        address proxy = Upgrades.deployUUPSProxy(
            "AgentBravoGovernor.sol", abi.encodeCall(AgentBravoGovernor.initialize, (dummyVotes, dummyTimelock, admin))
        );

        // Cast the proxy address to AgentBravoGovernor.
        instance = AgentBravoGovernor(payable(proxy));
    }

    function testName() public view {
        // The governor was initialized with the name "AgentBravoGovernor".
        assertEq(instance.name(), "AgentBravoGovernor");
    }

    function testProposalDescriptionStorage() public {
        // Prepare parameters for a proposal with one dummy target.
        address[] memory targets = new address[](1);
        targets[0] = address(this); // a dummy address for the proposal call
        uint256[] memory values = new uint256[](1);
        values[0] = 0;
        bytes[] memory calldatas = new bytes[](1);
        calldatas[0] = "";
        string memory proposalDesc = "Test proposal description";

        // Create a proposal. This calls _propose internally where the proposal description is stored.
        instance.propose(targets, values, calldatas, proposalDesc);

        // Compute the description hash as done in _propose.
        bytes32 descHash = keccak256(abi.encodePacked(proposalDesc));

        // Retrieve the stored description using the getter.
        string memory storedDesc = instance.getProposalDescription(descHash);

        // Validate that the stored description equals the original proposal description.
        assertEq(storedDesc, proposalDesc, "Proposal description was not stored correctly on-chain");
    }
}
