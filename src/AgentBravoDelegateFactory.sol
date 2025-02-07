// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./AgentBravoDelegate.sol";

/**
 * @title AgentBravoDelegateFactory
 * @notice Factory contract for deploying minimal proxy clones of AgentBravoDelegate.
 */
contract AgentBravoDelegateFactory is Ownable {
    /// @notice Address of the AgentBravoDelegate implementation used for cloning.
    address public implementation;

    /// @notice Array of all deployed AgentBravoDelegate clones.
    address[] public deployedAgents;

    /// @notice Emitted when a new AgentBravoDelegate clone has been deployed.
    event AgentBravoDelegateDeployed(address cloneAddress);

    /// @notice Emitted when the implementation address is updated.
    event ImplementationUpdated(address newImplementation);

    /**
     * @notice Constructor to set the AgentBravoDelegate implementation address.
     * @param _implementation The address of the deployed AgentBravoDelegate master copy.
     */
    constructor(address _implementation) Ownable(msg.sender) {
        require(_implementation != address(0), "Invalid implementation address");
        implementation = _implementation;
    }

    /**
     * @notice Deploys a new AgentBravoDelegate clone and initializes it.
     * @param _governor The address of the governor to be associated with the clone.
     * @param _owner The address to be set as the owner of the clone.
     * @return clone The address of the deployed clone.
     */
    function deployAgentBravoDelegate(address _governor, address _owner) external returns (address clone) {
        clone = Clones.clone(implementation);
        AgentBravoDelegate(clone).initialize(_governor, _owner);
        deployedAgents.push(clone);
        emit AgentBravoDelegateDeployed(clone);
    }

    /**
     * @notice Updates the AgentBravoDelegate implementation address used for cloning.
     * @param newImplementation The new implementation address.
     *
     * Requirements:
     *
     * - Only the contract owner can call this function.
     * - The new implementation address must be non-zero.
     */
    function updateImplementation(address newImplementation) external onlyOwner {
        require(newImplementation != address(0), "Invalid implementation address");
        implementation = newImplementation;
        emit ImplementationUpdated(newImplementation);
    }

    /**
     * @notice Returns the number of AgentBravoDelegate clones deployed by the factory.
     * @return count The total number of deployed clones.
     */
    function getDeployedAgentsCount() external view returns (uint256 count) {
        return deployedAgents.length;
    }
}
