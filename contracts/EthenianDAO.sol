/******************************************************************************\

file:   EthenianDAO.sol
ver:    0.0.3-alpha
updated:19-Dec-2016
author: Darryl Morris (o0ragman0o)
email:  o0ragman0o AT gmail.com

This file is part of the Ethenian DAO framework

This software is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
See MIT Licence for further details.
<https://opensource.org/licenses/MIT>.

\******************************************************************************/

import "Interfaces.sol";
import "Matter.sol";
import "Member.sol";
import "Authority.sol";
import "AddressRegistrar.sol";


pragma solidity ^0.4.0;


contract EthenianDAO is Base
{
    string constant public VERSION = "EthenianDAO 0.0.3-alpha";
    AddressRegistrar public contracts = new AddressRegistrar();
    
/* EthenianDAO Standard public functions */

    // Returns the attritian tax rate per block
    function attritionTaxRate()
        public
        constant
        returns (uint aTR_)
    {
        address matReg = contracts.namedAddress("attritionTaxRate");
        aTR_ = matReg == 0x0 ?
            0 : MatterInterface(matReg).average();
    }
    
    function withdrawalTaxRate()
        public
        constant
        returns (uint wTR_)
    {
        address matReg = contracts.namedAddress("withdrawlTaxRate");
        wTR_ = matReg == 0x0 ?
            0 : MatterInterface(matReg).average();
    }
    
    function minimumVoteBalance()
        public
        constant
        returns (uint minVB_)
    {
        address matReg = contracts.namedAddress("minimumVoteBalance");
        minVB_ = matReg == 0x0 ?
            0 : MatterInterface(matReg).average();
    }
    
    function maximumVoteBalance()
        public
        constant
        returns (uint maxVB_)
    {
        address matReg = contracts.namedAddress("maximumVoteBalance");
        maxVB_ = matReg == 0x0 ?
            0 : MatterInterface(matReg).average();
    }
    
    function getMatter(uint _matterId)
        public
        constant
        returns (address matter_)
    {
        matter_ = Matter(contracts.idAddress(_matterId));
    }
    
    function authority()
        public
        constant
        returns (address auth_)
    {
        auth_ = Authority(contracts.namedAddress("authority"));
    }
    

/* Public Function */ 

    // To set core and custom contract addresses.
    function setContract(bytes32 _name, address _addr)
        public
        onlyOwner
        canEnter
        returns (bool)
    {
        contracts.add(_name, _addr, false);
        return SUCCESS;
    }
    
    function getByName(bytes32 _name)
        public
        constant
        returns (address addr_)
    {
        addr_ = contracts.namedAddress(_name);
        return;
    }

    function getById(uint _id)
        public
        constant
        returns (address addr_)
    {
        addr_ = contracts.idAddress(_id);
        return;
    }
    
    function newMember(bytes32 _name)
        public
        returns (address member_)
    {
        address memFactory = contracts.namedAddress("memberFactory");

        member_ = MemberFactory(memFactory).createNew(this, _name, msg.sender);
        contracts.add(_name, member_, false);
        return;
    }

    function newMatter(bytes32 _name, string _url)
        public
        returns (address matter_)
    {
        address matFactory = contracts.namedAddress("matterFactory");

        matter_ = MatterFactory(matFactory).
            createNew(this, contracts.size(), _name, _url);
        contracts.add(_name, matter_, false);
        return;
    }
}