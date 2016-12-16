/******************************************************************************\

file:   Member.sol
ver:    0.0.1-alpha
updated:16-Dec-2016
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

import "Base.sol";
import "EthenianDAO.sol";
import "Matter.sol";


contract Member is Base
{

/* Constants */

    string constant public VERSION = "Member 0.0.1-alpha";
    
    // 100 tokens == 100% 
    uint constant MAXTOKENS = 100;

/* Structs */

    struct Vote {
        uint votingTokens;
        uint votes;
    }

/* State Variable */

    EthenianDAO public dao;
    uint public lastActiveBalance;
    uint public lastActiveBlock;
    uint public fundedCredits;
    uint public taxCredits;
    uint public fundedTaxCredits;
    string public name;

    //
    mapping (uint => mapping (uint => Vote)) currentVotes;

    // Delegates are members this member has awarded voting power to
    // matterId -> delegate -> awarded voting power;
    mapping (uint => address[]) public delegates;

    // Constituents are members who have awarded this member their voting power
    // matterId -> constituent -> awarded voting power
    mapping (uint => mapping (address => Vote)) public constituents;
    
    
/* Modifiers */
    
    modifier onlyVoters()
    {
        // TODO validate caller through MembersRegistrar
        _;
    }
    
    modifier notOwner()
    {
        if (msg.sender == owner) throw;
        _;
    }
    
    // Validate tokens for voting or delegation
    modifier validTokens(uint _matterId, uint _votingTokens)
    {
        if (MAXTOKENS <
            constituents[_matterId][this].votingTokens + _votingTokens) throw;
        _;
    }
    
    modifier payWithdrawalTax()
    {
        uint taxOwed = attritionTaxOwed() +
            dao.withdrawalTaxBlocks() * dao.attritionTaxRate();
        uint txCredits = taxCredits;
        uint fndCredits = fundedCredits;
        
        // Tax against Funding Credits first
        if (taxOwed > 0) {
            if (fndCredits < taxOwed) {
                taxOwed -= fndCredits;
                fndCredits = 0;
            }
        } else {
                fndCredits -= taxOwed;
                taxOwed = 0;
        }
        // Only tax ether balance if not enough fundingCredit    
        if (taxOwed > 0) {
            txCredits += this.balance < taxOwed ? this.balance : taxOwed;
        }
        if (txCredits != taxCredits) taxCredits = txCredits;
        if (fndCredits != fundedCredits) fundedCredits = fndCredits;
        _;
    }
    
    modifier payAttritionTax()
    {
        uint attTax = attritionTaxOwed();
        
        // Tax against Funding Credits first
        if (attTax > 0) {
            if (fundedCredits < attTax) {
                attTax -= fundedCredits;
                fundedCredits = 0;
            }
        } else {
                fundedCredits -= attTax;
                attTax = 0;
        }
        // Only tax ether balance if not enough fundingCredit    
        if (attTax > 0) {
            taxCredits += this.balance < attTax ? this.balance : attTax;
        }
        _;
    }
    
    modifier hasEther(uint _amount)
    {
        if(_amount > this.balance - taxCredits) throw;
        _;
    }

    modifier updateVotingBalance()
    {
       _; 
    }
    // Handles activity updates to tax
    modifier touch()
    {
        // TODO
        // TODO lastActive = msg.block;
        // TODO update taxCredits, fundingCredits
        // TODO Orphan check
        // touchIntl();
        lastActiveBlock = block.number;
        _;
    }
    
    function Member(address _dao, string _name, address _externalOwner)
        public
    {
        dao = EthenianDAO(_dao);
        name = _name;
        owner = _externalOwner;
        lastActiveBlock = block.number;
        lastActiveBalance = msg.value;
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
        wdlTax_ = dao.withdrawalTaxBlocks() * dao.attritionTaxRate();
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
        base_ = this.balance + fundedCredits + taxCredits;
        base_ = base_ < maxVB ? base_ : maxVB;
    }
    
    // Total votes includes vote that have been delegated to the member
    function totalVotes(uint _matterId)
        public
        constant
        returns (uint votes_)
    {
        votes_ = constituents[_matterId][0].votes + baseVotes() * MAXTOKENS;
    }
    
    function getAwardedFrom(uint _matterId, address _constituent)
        public
        constant
        returns (uint[2])
    {
        return [
            constituents[_matterId][_constituent].votingTokens,
            constituents[_matterId][_constituent].votes
        ];
    }
    
    // To register a preference for an option in a matter
    function vote(uint _matterId, uint _optionId, uint _votingTokens)
        external
        onlyOwner
        canEnter
        payAttritionTax
        updateVotingBalance
        validTokens(_matterId, _votingTokens)
        touch
        returns (bool)
    {
        uint votes; 
        Matter matter = dao.getMatter(_matterId);

        // Token accouting
        uint deltaTokens = _votingTokens -
            currentVotes[_matterId][_optionId].votingTokens;
            
        currentVotes[_matterId][_optionId].votingTokens = _votingTokens;
        
        // Adjust tokens left available for voting
        constituents[_matterId][this].votingTokens += deltaTokens;
        
        // Votes accounting
        votes = _votingTokens * totalVotes(_matterId)/MAXTOKENS;
        
        matter.vote(_optionId, votes);
        return SUCCESS;
    }
    
    // Transfer votes to another member for all (matterId ==0) 
    // or a particular matter
    function delegateVotes(uint _matterId, uint _votingTokens, Member _delegate)
        public
        onlyOwner
        canEnter  // reentry protection prevents delegate loops
        touch
        validTokens(_matterId, _votingTokens)
        returns (bool success_)
    {
        uint[2] memory oldAward = _delegate.getAwardedFrom(_matterId, this);
        uint transferVotes = 
            (_votingTokens * totalVotes(_matterId)/MAXTOKENS) - oldAward[1];
        _votingTokens = _votingTokens - oldAward[0];
            
        // Take from current voting balance.
        constituents[_matterId][0].votes -= transferVotes;

        // Give to delegate
        _delegate.delegate(_matterId, _votingTokens, transferVotes);
        success_ =  SUCCESS;
    }
    
    // Recieve voting power from another member for all or a particular matter
    function delegate(uint _matterId, uint _votingTokens, uint _votes)
        public
        onlyVoters
        canEnter
        returns (bool)
    {
        constituents[_matterId][0].votes += _votes;
        // Record votes and voting tokens of the constituent 
        constituents[_matterId][msg.sender].votingTokens += _votingTokens;
        constituents[_matterId][msg.sender].votes += _votes;
        return SUCCESS;
    }
    
    function raiseMatter(string _name)
        external
        onlyOwner
        canEnter
        returns (Matter)
    {
        return dao.newMatter(_name);
    }
    
    function addOption(uint _matterId, uint _value, address _recipient,
        string _description)
        external
        onlyOwner
        canEnter
        returns (uint)
    {
        return dao.getMatter(_matterId).addOption(_value, _recipient,
            _description);
    }
    
    function fundMatter(uint _matterId, uint _amount)
        external
        onlyOwner
        canEnter
        touch
        returns (bool)
    {
        fundedCredits += _amount;
        Matter matter = Matter(dao.mattersRegistrar().get(_matterId));
        if(!matter.fund(_amount)) throw;
    }
    
    function withdraw(uint _amount)
        public
        onlyOwner
        canEnter
        payWithdrawalTax
        hasEther(_amount)
        returns (bool)
    {
        safeSend(owner, _amount);
        return SUCCESS;
    }
    
/* Internal Functions */

    
// TODO
//     function reVote(uint _matterId)
//         internal
//         returns (bool)
//     {
//         Matter matter = Matter(dao.mattersRegistrar().get(_matterId));
//     }
    
//     function touchIntl() {
//         uint blockDelta = block.number - lastActiveBlock;
//         uint attrTaxCredits = blockDelta * dao.attritionTaxRate();
//         if (fundedCredits > 0) {
//             if (fundedCredits > attrTaxCredits) {
//                 fundedCredits -= attrTaxCredits;
//             } else {
//                 attrTaxCredits -= fundedCredits;
//                 fundedCredits = 0;
//             }
//         }
// //        if ()
        
//     }
}



contract MemberFactory
{
    function createNew(address _dao, string _name, address _owner)
        public
        returns (Member)
    {
        Member member = new Member(_dao, _name, _owner);
        return member;
    }
}


