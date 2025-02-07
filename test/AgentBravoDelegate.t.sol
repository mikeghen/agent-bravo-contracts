// SPDX-License-Identifier: Apache 2.0
pragma solidity ^0.8.22;

import "forge-std/Test.sol";
import {AgentBravoDelegate, IGovernor} from "src/AgentBravoDelegate.sol";


/// @dev DummyGovernor implements AgentBravoDelegate.IGovernor so that we can simulate governance interactions.
contract DummyGovernor is IGovernor {
    uint256 public proposalCounter;

    /// @notice For testing purposes, castVote returns a weight based on the vote support.
    /// Support 0 returns 100, support 1 returns 200, support 2 returns 300.
    function castVote(uint256 /*proposalId*/, uint8 support) external pure override returns (uint256) {
        if (support == 0) {
            return 100;
        } else if (support == 1) {
            return 200;
        } else if (support == 2) {
            return 300;
        }
        revert("Invalid support");
    }
    
    /// @notice For testing propose, we increment a counter and return it as the proposalId.
    function propose(
        address[] memory /*targets*/,
        uint256[] memory /*values*/,
        bytes[] memory /*calldatas*/,
        string memory /*description*/
    ) external override returns (uint256) {
        proposalCounter++;
        return proposalCounter;
    }
}

/// @title AgentBravoDelegateTest
/// @dev Tests for the AgentBravoDelegate contract functionality.
contract AgentBravoDelegateTest is Test {
    DummyGovernor public dummyGovernor;
    AgentBravoDelegate public delegate;
    address public owner;
    address public nonOwner;

    function setUp() public {
        owner = address(this); // Test contract is the owner.
        nonOwner = address(0xbeef); // Arbitrary non-owner address.
        dummyGovernor = new DummyGovernor();
        delegate = new AgentBravoDelegate();
        // Call initialize since the new version is initializable.
        delegate.initialize(address(dummyGovernor), owner);
    }

    function testInitialGovernorIsSet() public view {
        assertEq(address(delegate.governor()), address(dummyGovernor));
    }

    function testPublishOpinionAndVote() public {
        uint256 proposalId = 1;
        uint8 support = 1; // Vote "For" (should return 200)
        string memory opinionText = "This is my opinion";
        string memory reasoningText = "Because it benefits the community";

        uint256 voteWeight = delegate.publishOpinionAndVote(
            proposalId,
            support,
            opinionText,
            reasoningText
        );
        // DummyGovernor returns 200 for support == 1.
        assertEq(voteWeight, 200);

        // Retrieve the stored opinion and validate the fields.
        AgentBravoDelegate.Opinion memory op = delegate.getOpinion(proposalId);
        assertEq(op.proposalId, proposalId);
        assertEq(op.support, support);
        assertEq(op.opinion, opinionText);
        assertEq(op.reasoning, reasoningText);
        assertGt(op.timestamp, 0);
    }

    function testPublishOpinionAndVoteFailsForInvalidSupport() public {
        uint256 proposalId = 1;
        uint8 invalidSupport = 3; // Not allowed (only 0, 1, or 2 permitted)
        string memory opinionText = "Some opinion";
        string memory reasoningText = "Invalid support";

        vm.expectRevert("Invalid vote type");
        delegate.publishOpinionAndVote(proposalId, invalidSupport, opinionText, reasoningText);
    }

    function testPublishOpinionAndVoteFailsIfAlreadyVoted() public {
        uint256 proposalId = 2;
        uint8 support = 1;
        string memory opinionText = "Opinion text";
        string memory reasoningText = "Repeated vote";

        // First call should succeed.
        delegate.publishOpinionAndVote(proposalId, support, opinionText, reasoningText);
        // A second call for the same proposal should revert.
        vm.expectRevert("Vote already cast for this proposal");
        delegate.publishOpinionAndVote(proposalId, support, opinionText, reasoningText);
    }

    function testVoteFunction() public {
        uint256 proposalId = 3;
        uint8 support = 2; // Should return 300
        uint256 voteWeight = delegate.vote(proposalId, support);
        assertEq(voteWeight, 300);
    }

    function testProposeFunction() public {
        address[] memory targets = new address[](1);
        targets[0] = address(0x123);
        uint256[] memory values = new uint256[](1);
        values[0] = 0;
        bytes[] memory calldatas = new bytes[](1);
        calldatas[0] = hex"";
        string memory description = "Test proposal";

        uint256 returnedProposalId = delegate.propose(targets, values, calldatas, description);
        // Since DummyGovernor proposalCounter starts at 0, the first proposalId should be 1.
        assertEq(returnedProposalId, 1);

        // Propose a second proposal; then proposalCounter should be 2.
        uint256 secondProposalId = delegate.propose(targets, values, calldatas, "Another proposal");
        assertEq(secondProposalId, 2);
    }

    function testOnlyOwnerRestriction() public {
        uint256 proposalId = 4;
        uint8 support = 1;
        string memory opinionText = "Non-owner test";
        string memory reasoningText = "Should revert";

        // Attempt to publish opinion and vote from a non-owner should revert.
        vm.prank(nonOwner);
        vm.expectRevert("Ownable: caller is not the owner");
        delegate.publishOpinionAndVote(proposalId, support, opinionText, reasoningText);

        // Attempt to call vote from non-owner should revert.
        vm.prank(nonOwner);
        vm.expectRevert("Ownable: caller is not the owner");
        delegate.vote(proposalId, support);

        // Attempt to call propose from non-owner should revert.
        address[] memory targets = new address[](1);
        targets[0] = address(0xabc);
        uint256[] memory values = new uint256[](1);
        values[0] = 0;
        bytes[] memory calldatas = new bytes[](1);
        calldatas[0] = hex"";
        vm.prank(nonOwner);
        vm.expectRevert("Ownable: caller is not the owner");
        delegate.propose(targets, values, calldatas, "Non-owner proposal");
    }

    /// @notice Verifies that the owner can update and then read the VotingPolicy parameters.
    function testUpdateVotingPolicyAndRead() public {
        string memory backstory = "You're a seasoned delegate with experience reviewing governance proposals...";
        string memory voteNoConditions = "The proposal does not clearly demonstrate a return on investment (ROI) of at least 10% annually.";
        string memory voteYesConditions = "The proposal clearly demonstrates a return on investment (ROI) of 10% or more annually.";
        string memory voteAbstainConditions = "The proposal's return on investment (ROI) cannot be accurately determined from the provided information.";

        // Update the voting policy as the owner.
        delegate.updateVotingPolicy(backstory, voteNoConditions, voteYesConditions, voteAbstainConditions);

        // Retrieve the stored VotingPolicy data.
        (string memory storedBackstory,
         string memory storedVoteNoConditions,
         string memory storedVoteYesConditions,
         string memory storedVoteAbstainConditions) = delegate.votingPolicy();

        // Verify the stored values match our inputs.
        assertEq(storedBackstory, backstory);
        assertEq(storedVoteNoConditions, voteNoConditions);
        assertEq(storedVoteYesConditions, voteYesConditions);
        assertEq(storedVoteAbstainConditions, voteAbstainConditions);
    }

    /// @notice Verifies that a non-owner cannot update the VotingPolicy.
    function testUpdateVotingPolicyNonOwnerRevert() public {
        string memory backstory = "Test Backstory";
        string memory voteNoConditions = "Test NO Conditions";
        string memory voteYesConditions = "Test YES Conditions";
        string memory voteAbstainConditions = "Test ABSTAIN Conditions";

        // Attempt to update voting policy from a non-owner address.
        vm.prank(nonOwner);
        vm.expectRevert("Ownable: caller is not the owner");
        delegate.updateVotingPolicy(backstory, voteNoConditions, voteYesConditions, voteAbstainConditions);
    }
} 