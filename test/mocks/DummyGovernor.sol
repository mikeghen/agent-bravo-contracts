// SPDX-License-Identifier: Apache 2.0
pragma solidity ^0.8.22;

import {IGovernor} from "src/AgentBravoDelegate.sol";

/// @dev DummyGovernor implements IGovernor so that we can simulate governance interactions.
contract DummyGovernor is IGovernor {
    uint256 public proposalCounter;

    /// @notice For testing purposes, castVote returns a weight based on the vote support.
    /// Support 0 returns 100, support 1 returns 200, support 2 returns 300.
    function castVote(uint256, uint8 support) external pure override returns (uint256) {
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
        address[] memory,
        uint256[] memory,
        bytes[] memory,
        string memory
    ) external override returns (uint256) {
        proposalCounter++;
        return proposalCounter;
    }
} 