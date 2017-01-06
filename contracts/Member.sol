/******************************************************************************\

file:   Member.sol
ver:    0.0.5-sandalstraps
updated:6-Jan-2017
author: Darryl Morris (o0ragman0o)
email:  o0ragman0o AT gmail.com

This file is part of the Ethenian DAO framework

This software is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
See MIT Licence for further details.
<https://opensource.org/licenses/MIT>.

\******************************************************************************/

pragma solidity ^0.4.0;

import "DAOAccount.sol";

contract Member is DAOAccount
{

/* Constants */

    string constant public VERSION = "Member 0.0.4-alpha";
    
    // 100 tokens == 100% 
    uint constant MAXTOKENS = 100;
    // Using fixed point decimal maths for divisions
    // TODO optomise fixed point
    uint constant FIXEDPOINT = 10**5;
    
    // Maximum depth of Delegation tree
    uint constant MAXDEPTH = 5;

/* Structs */
    struct Vote {
        uint votingTokens;
        uint votes;
    }


/* State Variable */

    bytes32 public name;
    DAOAccount public taxAccount;
    
    // matterName -> optionId -> awarded votes
    mapping (bytes32 => mapping (uint => Vote)) public currentVotes;

    // Delegates are members this member has awarded voting power to
    // matterName -> delegate name -> awareded tokens
    // mapping (bytes32 => address[]) public delegates;
    mapping (bytes32 => mapping(bytes32 => uint)) public delegates;
    mapping (bytes32 => uint) public numDelegates;

    // Constituents are members who have awarded this member their voting power
    // A member is their own constituent and their votes are recorded here also
    // matterName -> constituent -> awarded voting power
    mapping (bytes32 => mapping (address => Vote)) public constituents;
    
    
    
/* Modifiers */
    
    modifier onlyVoters()
    {
        // TODO validate caller through MembersRegistrar
        _;
    }
    
    // Validate tokens for voting or delegation
    modifier validTokens(bytes32 _matterName, uint _votingTokens)
    {
        if (MAXTOKENS <
            constituents[_matterName][this].votingTokens + _votingTokens) throw;
        _;
    }
    
    modifier payWithdrawalTax()
    {
        // uint taxOwed = attritionTaxOwed() +
        //     dao.withdrawalTaxBlocks() * dao.attritionTaxRate();
        // uint txCredits = taxCredits;
        // uint fndCredits = fundedCredits;
        
        // // Tax against Funding Credits first
        // if (taxOwed > 0) {
        //     if (fndCredits < taxOwed) {
        //         taxOwed -= fndCredits;
        //         fndCredits = 0;
        //     }
        // } else {
        //         fndCredits -= taxOwed;
        //         taxOwed = 0;
        // }
        // // Only tax ether balance if not enough fundingCredit    
        // if (taxOwed > 0) {
        //     txCredits += this.balance < taxOwed ? this.balance : taxOwed;
        // }
        // if (txCredits != taxCredits) taxCredits = txCredits;
        // if (fndCredits != fundedCredits) fundedCredits = fndCredits;
        _;
    }
    
    modifier payAttritionTax()
    {
        // uint attTax = attritionTaxOwed();
        
        // // Tax against Funding Credits first
        // if (attTax > 0) {
        //     if (fundedCredits < attTax) {
        //         attTax -= fundedCredits;
        //         fundedCredits = 0;
        //     }
        // } else {
        //         fundedCredits -= attTax;
        //         attTax = 0;
        // }
        // // Only tax ether balance if not enough fundingCredit    
        // if (attTax > 0) {
        //     taxCredits += this.balance < attTax ? this.balance : attTax;
        // }
        _;
    }
    
    modifier updateVotingBalance()
    {
      _; 
    }
    // Handles activity updates to tax
    
    function Member(address _dao, bytes32 _name, address _externalOwner)
        public
        DAOAccount(_dao, _externalOwner)
    {
        name = _name;
    }
    
    function ()
        payable
        touch
    {
        lastActiveBalance = this.balance;
    }
    
    function withdrawableBalance()
        public
        constant
        returns (uint sansTax_)
    {
        sansTax_ = this.balance - (withdrawalTax() + attritionTaxOwed());
    }
    
    function withdrawalTax()
        public
        constant
        returns (uint wdlTax_)
    {
        wdlTax_ = dao.withdrawalTaxRate() * dao.attritionTaxRate();
    }
    
    function attritionTaxOwed()
        public
        constant
        returns (uint attTax_)
    {
        attTax_ = (block.number - lastActiveBlock) * dao.attritionTaxRate();
    }
    
    // Base votes is the owners own voting balance according to their investment
    function baseVotes()
        public
        constant
        returns (uint base_)
    {
        uint maxVB = dao.maximumVoteBalance();
        uint minVB = dao.minimumVoteBalance();
        base_ = this.balance + fundedCredits + 
            (address(taxAccount) == 0x0 ? 0 : taxAccount.balance);
        base_ = base_ > maxVB ? maxVB : base_;
        base_ = base_ < minVB ? 0 : base_;
    }
    
    // Total votes includes vote that have been delegated to the member
    function totalVotes(bytes32 _matterName)
        public
        constant
        returns (uint votes_)
    {
        uint bv = baseVotes();
        uint maxVB = dao.maximumVoteBalance();
        votes_ = maxVB == 0 ? 0 :
            // ((constituents[_matterName][0].votes + bv) * (bv * FIXEDPOINT)/
            // maxVB) / FIXEDPOINT;
            constituents[_matterName][0].votes + bv;
    }
    
    function getDelegatesFor(bytes32 _matterName)
        public
        constant
        returns (address[])
    {
        address[] memory dlgts = new address[](numDelegates[_matterName]);
        for(uint i=0; i<numDelegates[_matterName]; i++){
            dlgts[i] = address(delegates[_matterName][bytes32(i+1)]);
        }
        return dlgts;
    }
    
    function getConstituentVotesFrom(bytes32 _matterName, Member _constituent)
        public
        constant
        returns (uint[2])
    {
        return [
            constituents[_matterName][_constituent].votingTokens,
            constituents[_matterName][_constituent].votes
            ];
    }
    
    
    // To register a preference for an option in a matter
    function vote(bytes32 _matterName, uint _optionId, uint _votingTokens)
        external
        onlyOwner
        canEnter
        payAttritionTax
        updateVotingBalance
//        validTokens(_matterName, _votingTokens)
        touch
    {
        uint votes; 
        Matter matter = Matter(dao.getMatter(_matterName));

        // Token accouting
        uint deltaTokens = _votingTokens -
            currentVotes[_matterName][_optionId].votingTokens;
            
        currentVotes[_matterName][_optionId].votingTokens = _votingTokens;
        
        // Adjust tokens left available for voting
        constituents[_matterName][this].votingTokens += deltaTokens;
        
        // Votes accounting
        votes = (_votingTokens * totalVotes(_matterName)/MAXTOKENS) -
            currentVotes[_matterName][_optionId].votes;
        currentVotes[_matterName][_optionId].votes += votes;
        
        matter.vote(_optionId, votes);
    }
    
    
    // TODO propagate through and limit delegate tree depth
    // Transfer votes to another member for all (matterId ==0) 
    // or a particular matter
    function delegateVotesTo(bytes32 _matterName, bytes32 _delegateName,
            uint _votingTokens)
        public
        onlyOwner
        canEnter  // reentry protection prevents delegate loops
        touch
        validTokens(_matterName, _votingTokens)
    {
        Member delegate = Member(dao.getMember(_delegateName));
        // uint[2] memory oldAward = delegate.constituents(_matterName, this);
        uint[2] memory oldAward = delegate.
            getConstituentVotesFrom(_matterName, this);
        uint transferVotes = 
            (_votingTokens * totalVotes(_matterName)/MAXTOKENS) - oldAward[1];
        _votingTokens = _votingTokens - oldAward[0];
            
        // Take from current voting balance.
        constituents[_matterName][0].votes -= transferVotes;

        // Record delegate
        // delegates[_matterName].push(delegate);
        if (delegates[_matterName][bytes32(address(delegate))] == 0) {
            numDelegates[_matterName] += 1;
            delegates[_matterName][bytes32(numDelegates[_matterName])] = 
                uint(delegate);
            delegates[_matterName][bytes32(address(delegate))] = 
                uint(numDelegates[_matterName]);
        }
        
        // Give to delegate
        delegate.recieveConstituentVotes(_matterName, _votingTokens,
            transferVotes);
    }
    
    // Recieve voting power from another member for all or a particular matter
    function recieveConstituentVotes(bytes32 _matterName, uint _votingTokens,
            uint _votes)
        public
        onlyVoters
        canEnter
    {
        constituents[_matterName][0].votes += _votes;
        // Record votes and voting tokens of the constituent 
        constituents[_matterName][msg.sender].votingTokens += _votingTokens;
        constituents[_matterName][msg.sender].votes += _votes;
    }
    
    function raiseMatter(bytes32 _name, string _url)
        external
        onlyOwner
        canEnter
    {
        dao.newMatter(_name, _url);
    }
    
    function addOption(bytes32 _matterName, bytes32 _optionName, uint _value,
        address _recipient)
        external
        onlyOwner
        canEnter
    {
        Matter(dao.getMatter(_matterName)).
            addOption(_optionName, _value, _recipient);
    }
    
    function withdraw(uint _amount)
        public
        onlyOwner
        canEnter
        payWithdrawalTax
        hasEther(_amount)
    {
        safeSend(owner, _amount);
    }
    
/* Internal Functions */

    
// TODO
//     function reVote(uint _matterId)
//         internal
//         returns (bool)
//     {
//         Matter matter = Matter(dao.mattersRegistrar().get(_matterId));
//     }

}


contract MemberFactory
{
    string constant public VERSION = "MemberFactory 0.0.4-alpha";
    Member public last;
    event Created(bytes32 _name, address _addr);
    
    function createNew(bytes32 _name, address _owner)
        public
    {
        last = new Member(msg.sender, _name, _owner);
        Created(_name, last);
    }
}


