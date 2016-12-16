/******************************************************************************\

file:   EthenianDAO.sol
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

import "Base.sol";
import "Authority.sol";
import "Member.sol";
import "Matter.sol";
import "MembersRegistrar.sol";
import "MattersRegistrar.sol";


pragma solidity ^0.4.0;


contract EthenianDAO is Base
{
    string constant public VERSION = "EthenianDAO 0.0.1-alpha";
    mapping (string => address) contracts;

    // To get core and custom contract addresses
    function getContract(string _name)
        public
        constant
        returns (address)
    {
        return contracts[_name];
    }

/* EthenianDAO Standard public functions */

    // Returns the attritian tax rate per block
    function attritionTaxRate()
        public
        constant
        returns (uint aTR_)
    {
        aTR_ = contracts["attritionTaxRate"] == 0x0 ?
            0 : Matter(contracts["attritionTaxRate"]).average();
    }
    
    function withdrawalTaxBlocks()
        public
        constant
        returns (uint wTR_)
    {
        wTR_ = contracts["withdrawalTaxRate"] == 0x0 ?
            0: Matter(contracts["withdrawalTaxRate"]).average();
    }
    
    function minimumVoteBalance()
        public
        constant
        returns (uint minVB_)
    {
        minVB_ = contracts["minimumVoteBalance"]  == 0x0 ?
            0 : Matter(contracts["minimumVoteBalance"]).average();
    }
    
    function maximumVoteBalance()
        public
        constant
        returns (uint maxVB_)
    {
        maxVB_ = contracts["maximumVoteBalance"] == 0x0 ?
            2**128 : Matter(contracts["maximumVoteBalance"]).average();
    }
    
    function membersRegistrar()
        public
        constant
        returns (MembersRegistrar)
    {
        return MembersRegistrar(contracts["membersRegistrar"]);
    }

    function mattersRegistrar()
        public
        constant
        returns (MattersRegistrar)
    {
        return MattersRegistrar(contracts["mattersRegistrar"]);
    }
    
    function getMatter(uint _matterId)
        public
        constant
        returns (Matter)
    {
        return mattersRegistrar().get(_matterId);
    }
    
    function authority()
        public
        constant
        returns (Authority)
    {
        return Authority(contracts["authority"]);
    }


/* Public Function */ 

    // To set core and custom contract addresses.
    function setContract(string _name, address _addr)
        public
        onlyOwner
        canEnter
        returns (bool)
    {
        contracts[_name] = _addr;
        return true;
    }
    
    function newMember(string _name)
        public
        returns (Member member_)
    {
        member_ = membersRegistrar().newMember(_name, msg.sender);
        return;
    }

    function newMatter(string _description)
        public
        returns (Matter matter_)
    {
        matter_ = mattersRegistrar().newMatter(_description);
        return;
    }
}