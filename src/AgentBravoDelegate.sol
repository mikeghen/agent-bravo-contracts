// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title IGovernor
 * @notice Minimal interface for interacting with the AgentBravoGovernor.
 * The governor is expected to use OpenZeppelin's Governor implementation where
 * casting a vote is done by calling `castVote`.
 */
interface IGovernor {
    /**
     * @notice Cast a vote on a proposal.
     * @param proposalId The id of the proposal.
     * @param support The vote type (0 = Against, 1 = For, 2 = Abstain).
     * @return The weight of the vote cast.
     */
    function castVote(uint256 proposalId, uint8 support) external returns (uint256);
    function propose(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        string memory description
    ) external returns (uint256);
}

/**
 * @title AgentBravoDelegate
 * @notice This contract acts as an autonomous agent that can publish its on-chain
 * opinions and vote on governance proposals via the AgentBravoGovernor.
 *
 * The owner's address controls which account can execute vote actions.
 */
contract AgentBravoDelegate {
    /// Used to ensure the contract is only initialized once.
    bool private _initialized;

    /// @notice The owner of the contract.
    address public owner;

    /// @notice The governor contract against which votes will be cast.
    /// i.e. the governance project that the AgentBravo will participate in.
    IGovernor public governor;

    /// @notice Record of the opinion for proposals on which a vote was cast.
    struct Opinion {
        uint256 proposalId; // The id of the proposal
        uint8 support; // 0 = Against, 1 = For, 2 = Abstain
        string opinion; // The opinion of the AgentBravo
        string reasoning; // Explanation or accompanying reasoning for the vote
        uint256 timestamp; // When the opinion was published
    }

    /// @notice Holds information regarding the Agent's voting policy.
    struct VotingPolicy {
        string backstory;
        string voteNoConditions;
        string voteYesConditions;
        string voteAbstainConditions;
    }

    /// @notice Stores the Agent's voting policy information.
    VotingPolicy public votingPolicy;

    /// @notice Mapping from a proposal id to its associated opinion.
    mapping(uint256 => Opinion) public opinions;

    /// @notice Emitted when the owner of the contract is transferred.
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /// @notice Emitted when an opinion is published and a vote is cast.
    event OpinionPublished( // The index of the stored opinion (i.e. proposalId)
    uint256 indexed opinionIndex, address indexed publishedBy, uint256 voteWeight);

    /// @notice Emitted when the agent's voting policy information is updated.
    event VotingPolicyUpdated(
        string backstory, string voteNoConditions, string voteYesConditions, string voteAbstainConditions
    );

    /// @notice Modifier to restrict access to only the contract owner.
    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }

    /**
     * @notice Initializes the contract setting the governor and owner addresses.
     * @param _governor The address of the deployed AgentBravoGovernor.
     * @param newOwner The address to be set as the owner.
     *
     * Requirements:
     *
     * - Can only be called once.
     */
    function initialize(address _governor, address newOwner) external {
        require(!_initialized, "Already initialized");
        require(_governor != address(0), "Invalid governor address");
        require(newOwner != address(0), "Invalid owner address");

        governor = IGovernor(_governor);
        owner = newOwner;
        _initialized = true;
    }

    /**
     * @notice Transfers ownership of the contract to a new account.
     * @param newOwner The address to transfer ownership to.
     *
     * Requirements:
     *
     * - Only the current owner can call this function.
     * - New owner cannot be the zero address.
     */
    function transferOwnership(address newOwner) external {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        address oldOwner = owner;
        owner = newOwner;

        emit OwnershipTransferred(oldOwner, newOwner);
    }

    /**
     * @notice Updates the agent voting policy information.
     * @param _backstory The backstory of the agent.
     * @param _voteNoConditions Conditions under which the agent would vote NO.
     * @param _voteYesConditions Conditions under which the agent would vote YES.
     * @param _voteAbstainConditions Conditions under which the agent would vote ABSTAIN.
     *
     * Requirements:
     *
     * - Only the contract owner can call this function.
     */
    function updateVotingPolicy(
        string calldata _backstory,
        string calldata _voteNoConditions,
        string calldata _voteYesConditions,
        string calldata _voteAbstainConditions
    ) external onlyOwner {
        votingPolicy = VotingPolicy({
            backstory: _backstory,
            voteNoConditions: _voteNoConditions,
            voteYesConditions: _voteYesConditions,
            voteAbstainConditions: _voteAbstainConditions
        });
        emit VotingPolicyUpdated(_backstory, _voteNoConditions, _voteYesConditions, _voteAbstainConditions);
    }

    /**
     * @notice Publishes an opinion and votes on a proposal using the governor.
     * @param proposalId The id of the proposal to vote on.
     * @param support The type of vote (0 = Against, 1 = For, 2 = Abstain).
     * @param opinion The opinion of the AgentBravo.
     * @param reasoning The accompanying reasoning to be stored on chain.
     * @return voteWeight The weight returned by the governor after casting the vote.
     *
     * Requirements:
     *
     * - Only the contract owner can call this function.
     * - The `support` parameter must be 0, 1, or 2.
     * - The agent must not have already recorded an opinion for the given proposal.
     */
    function publishOpinionAndVote(
        uint256 proposalId,
        uint8 support,
        string calldata opinion,
        string calldata reasoning
    ) external onlyOwner returns (uint256 voteWeight) {
        // Allow only valid vote types (0 = Against, 1 = For, 2 = Abstain)
        require(support <= 2, "Invalid vote type");
        // Ensure the AgentBravo has not already voted on this proposal
        require(opinions[proposalId].timestamp == 0, "Vote already cast for this proposal");

        // Cast the vote through the governor.
        voteWeight = governor.castVote(proposalId, support);

        // Record the opinion and accompanying reasoning.
        opinions[proposalId] = Opinion({
            proposalId: proposalId,
            support: support,
            opinion: opinion,
            reasoning: reasoning,
            timestamp: block.timestamp
        });

        // Emit only the opinion index (proposalId) instead of full opinion details.
        emit OpinionPublished(proposalId, msg.sender, voteWeight);
    }

    /**
     * @notice Allows the agent to vote on a proposal without storing an accompanying opinion.
     * @param proposalId The id of the proposal.
     * @param support The vote type (0 = Against, 1 = For, 2 = Abstain).
     * @return voteWeight The vote weight as returned by the governor.
     *
     * Requirements:
     *
     * - Only the contract owner can call this function.
     * - The `support` parameter must be 0, 1, or 2.
     */
    function vote(uint256 proposalId, uint8 support) external onlyOwner returns (uint256 voteWeight) {
        require(support <= 2, "Invalid vote type");
        voteWeight = governor.castVote(proposalId, support);
    }

    /**
     * @notice Publishes a proposal through the governor.
     * @param targets Array of target addresses for proposal calls
     * @param values Array of ETH values for proposal calls
     * @param calldatas Array of calldata for proposal calls
     * @param description String description of the proposal
     * @return proposalId The ID of the created proposal
     *
     * Requirements:
     *
     * - Only the contract owner can call this function
     * - The arrays must be of equal length and non-empty
     */
    function propose(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        string memory description
    ) external onlyOwner returns (uint256) {
        return governor.propose(targets, values, calldatas, description);
    }

    /**
     * @notice Retrieves the opinion for a given proposal.
     * @param proposalId The id of the proposal.
     * @return The Opinion struct with details regarding the vote.
     */
    function getOpinion(uint256 proposalId) external view returns (Opinion memory) {
        return opinions[proposalId];
    }
}
