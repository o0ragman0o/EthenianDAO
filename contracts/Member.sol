/******************************************************************************\

file:   Member.sol
ver:    0.0.3-alpha
updated:23-Dec-2016
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

    string constant public VERSION = "Member 0.0.3-alpha";
    
    // 100 tokens == 100% 
    uint constant MAXTOKENS = 100;
    uint constant FIXEDPOINT = 10**5;

/* Structs */
    struct Vote {
        uint votingTokens;
        uint votes;
    }


/* State Variable */

    // TODO redundant store. name in registrar
    bytes32 memberName;
    DAOAccount public taxAccount;// = new DAOAccount();
    
    //
    mapping (bytes32 => mapping (uint => Vote)) currentVotes;

    // Delegates are members this member has awarded voting power to
    // matterId -> delegate -> awarded voting power;
    mapping (bytes32 => address[]) public delegates;

    // Constituents are members who have awarded this member their voting power
    // matterId -> constituent -> awarded voting power
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
        memberName = _name;
    }
    
    function ()
        payable
        touch
    {
        lastActiveBalance = this.balance;
    }
    
    function name()
        public
        constant
        returns (string)
    {
        uint name = uint(memberName);
        bytes memory bytesString = new bytes(32);
        for (uint j=0; j<32; j++) {
            byte char = byte(bytes32(name * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[j] = char;
            }
        }
        return string(bytesString);
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
        base_ = this.balance + fundedCredits + taxAccount.balance;
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
        votes_ = ((constituents[_matterName][0].votes + bv) * (bv * FIXEDPOINT)/
            maxVB) / FIXEDPOINT;
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
        validTokens(_matterName, _votingTokens)
        touch
        returns (bool)
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
        votes = _votingTokens * totalVotes(_matterName)/MAXTOKENS;
        
        matter.vote(_optionId, votes);
        return SUCCESS;
    }
    
    // Transfer votes to another member for all (matterId ==0) 
    // or a particular matter
    function delegateVotesTo(bytes32 _matterName, bytes32 _delegateName,
            uint _votingTokens)
        public
        onlyOwner
        canEnter  // reentry protection prevents delegate loops
        touch
        validTokens(_matterName, _votingTokens)
        returns (bool success_)
    {
        Member delegate = Member(dao.getMember(_delegateName));
        uint[2] memory oldAward = delegate.
            getConstituentVotesFrom(_matterName, this);
        uint transferVotes = 
            (_votingTokens * totalVotes(_matterName)/MAXTOKENS) - oldAward[1];
        _votingTokens = _votingTokens - oldAward[0];
            
        // Take from current voting balance.
        constituents[_matterName][0].votes -= transferVotes;

        // Give to delegate
        delegate.recieveConstituentVotes(_matterName, _votingTokens,
            transferVotes);
        success_ =  SUCCESS;
        return;
    }
    
    // Recieve voting power from another member for all or a particular matter
    function recieveConstituentVotes(bytes32 _matterName, uint _votingTokens,
            uint _votes)
        public
        onlyVoters
        canEnter
        returns (bool)
    {
        constituents[_matterName][0].votes += _votes;
        // Record votes and voting tokens of the constituent 
        constituents[_matterName][msg.sender].votingTokens += _votingTokens;
        constituents[_matterName][msg.sender].votes += _votes;
        return SUCCESS;
    }
    
    function raiseMatter(bytes32 _name, string _url)
        external
        onlyOwner
        canEnter
        returns (address matter_)
    {
        matter_ = dao.newMatter(_name, _url);
        return;
    }
    
    function addOption(bytes32 _matterName, bytes32 _optionName, uint _value,
        address _recipient)
        external
        onlyOwner
        canEnter
        returns (uint)
    {
        return Matter(dao.getMatter(_matterName)).
            addOption(_optionName, _value, _recipient);
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

}


contract MemberFactory
{
    string constant public VERSION = "MemberFactory 0.0.3-alpha";
    
    function createNew(bytes32 _name, address _owner)
        public
        returns (Member member_)
    {
        member_ = new Member(msg.sender, _name, _owner);
        return;
    }
}


