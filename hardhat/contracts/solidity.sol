// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RWA {
    address public owner;
    string public rwaName;

    struct Proposal {
        uint256 id;
        string title;
        string description;
        uint256 forVotes;
        uint256 againstVotes;
        bool executed;
        mapping(address => bool) votes;
    }

    struct Member {
        bool exists;
        bool active;
    }

    mapping(address => Member) public members;
    Proposal[] public proposals;
    uint256 public proposalCount;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    modifier onlyActiveMember() {
        require(members[msg.sender].active, "You are not an active member of the RWA");
        _;
    }

    event RWACreated(string name, address creator);
    event MemberAdded(address member);
    event MemberRemoved(address member);
    event ProposalCreated(uint256 proposalId, address creator);
    event Voted(uint256 proposalId, address voter, bool inFavor);

    constructor(string memory _rwaName, address[] memory initialMembers) {
        owner = msg.sender;
        rwaName = _rwaName;
        members[owner].exists = true;
        members[owner].active = true;

        for (uint256 i = 0; i < initialMembers.length; i++) {
            members[initialMembers[i]].exists = true;
            members[initialMembers[i]].active = true;
        }

        emit RWACreated(_rwaName, msg.sender);
    }

    function addMember(address newMember) external onlyOwner {
        require(!members[newMember].exists, "Member already exists");
        members[newMember].exists = true;
        emit MemberAdded(newMember);
    }

    function removeMember(address memberToRemove) external onlyOwner {
        require(memberToRemove != owner, "Cannot remove the owner from the RWA");
        require(members[memberToRemove].exists, "Member does not exist");
        members[memberToRemove].active = false;
        emit MemberRemoved(memberToRemove);
    }

    function createProposal(string memory title, string memory description) external onlyActiveMember {
        uint256 proposalId = proposalCount++;
        Proposal memory newProposal = Proposal({
            id: proposalId,
            title: title,
            description: description,
            forVotes: 0,
            againstVotes: 0,
            executed: false
        });
        proposals.push(newProposal);
        emit ProposalCreated(proposalId, msg.sender);
    }

    function vote(uint256 proposalId, bool inFavor) external onlyActiveMember {
        require(proposalId < proposalCount, "Invalid proposal ID");

        Proposal storage proposal = proposals[proposalId];
        require(!proposal.executed, "Proposal already executed");
        require(!proposal.votes[msg.sender], "Already voted");

        proposal.votes[msg.sender] = true;

        if (inFavor) {
            proposal.forVotes++;
        } else {
            proposal.againstVotes++;
        }

        emit Voted(proposalId, msg.sender, inFavor);
    }

    function executeProposal(uint256 proposalId) external onlyOwner {
        require(proposalId < proposalCount, "Invalid proposal ID");
        Proposal storage proposal = proposals[proposalId];
        require(!proposal.executed, "Proposal already executed");

        if (proposal.forVotes > proposal.againstVotes) {
            proposal.executed = true;
            // Implement the proposal execution logic here
        }
    }
}
