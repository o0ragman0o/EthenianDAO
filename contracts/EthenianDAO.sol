/******************************************************************************\

file:   EthenianDAO.sol
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

import "Base.sol";
import "Interfaces.sol";
import "Matter.sol";
import "Member.sol";
import "Authority.sol";
import "AddressRegistrar.sol";


pragma solidity ^0.4.0;

contract EthenianDAO is Base
{
    string constant public VERSION = "EthenianDAO 0.0.4-alpha";
    
    bytes32 public name;

    AddressRegistrarFactory bootstrap;
    AddressRegistrar public metaRegistrar;
    
    
/* EthenianDAO Standard public functions */

    function EthenianDAO(bytes32 _name, address _owner)
    {
        owner = _owner;
        name = _name;
        bootstrap = new AddressRegistrarFactory();
    }

    // Returns the attritian tax rate per block
    function attritionTaxRate()
        public
        constant
        returns (uint aTR_)
    {
        address matReg = AddressRegistrar(
            metaRegistrar.namedAddress("matters")).
                namedAddress("attritionTaxRate");
        aTR_ = matReg == 0x0 ?
            0 : MatterInterface(matReg).average();
    }
    
    function withdrawalTaxRate()
        public
        constant
        returns (uint wTR_)
    {
        address matReg = AddressRegistrar(
            metaRegistrar.namedAddress("matters")).
                namedAddress("withdrawlTaxRate");
        wTR_ = matReg == 0x0 ?
            0 : MatterInterface(matReg).average();
    }
    
    function minimumVoteBalance()
        public
        constant
        returns (uint minVB_)
    {
        address matReg = AddressRegistrar(
            metaRegistrar.namedAddress("matters")).
                namedAddress("minimumVoteBalance");
        minVB_ = matReg == 0x0 ?
            0 : MatterInterface(matReg).average();
    }
    
    function maximumVoteBalance()
        public
        constant
        returns (uint maxVB_)
    {
        address matReg = AddressRegistrar(
            metaRegistrar.namedAddress("matters")).
                namedAddress("maximumVoteBalance");
        maxVB_ = matReg == 0x0 ?
            uint(-1) : MatterInterface(matReg).average();
    }
    
    function getMatter(bytes32 _name)
        public
        constant
        returns (address matter_)
    {
        matter_ = AddressRegistrar(
            metaRegistrar.namedAddress("matters")).namedAddress(_name);
    }
    
    function getMember (bytes32 _name)
        public
        constant
        returns (address member_)
    {
        member_ = AddressRegistrar(
            metaRegistrar.namedAddress("members")).namedAddress(_name);
    }

    function getMemberFromOwner (address ownerAddr_)
        public
        constant
        returns (address member_)
    {
        member_ = AddressRegistrar(
            metaRegistrar.namedAddress("members")).
                namedAddress(sha3(ownerAddr_));
    }
    
    function authority()
        public
        constant
        returns (address auth_)
    {
        auth_ = metaRegistrar.namedAddress("authority");
        return;
    }

    function getElementNamedAddress(bytes32 _registrar, bytes32 _name)
        public
        constant
        returns (address addr_)
    {
        addr_ = AddressRegistrar(metaRegistrar.namedAddress(_registrar)).
            namedAddress(_name);
    }

    function getElementAddressId(bytes32 _registrar, address _addr)
        public
        constant
        returns (uint id_)
    {
        id_ = AddressRegistrar(metaRegistrar.namedAddress(_registrar)).
            addressId(_addr);
    }
 
    function getElementIdName(bytes32 _registrar, uint _id)
        public
        constant
        returns (bytes32 name_)
    {
        name_ = AddressRegistrar(metaRegistrar.namedAddress(_registrar)).
            idName(_id);
    }
    
    function getElementAddressName(bytes32 _registrar, address _addr)
        public
        constant
        returns (bytes32 name_)
    {
        name_ = getElementIdName(
            _registrar, getElementAddressId(_registrar, _addr));
    }
    
/* Public non-constant Functions */ 

    // To boostrap the central registry post deployment
    function init1()
        public
        onlyOwner
    {
        bootstrap.createNew();
        metaRegistrar = AddressRegistrar(bootstrap.last());
    }

    function init2()
        public
        onlyOwner
    {
        metaRegistrar.add("metaRegistrar",metaRegistrar,true);
        newRegistrar("factories",true);
        newRegistrar("members",true);
        newRegistrar("matters",true);
    }
    
    function newMember(bytes32 _name)
        public
    {
        address memFactory = AddressRegistrar(
            metaRegistrar.namedAddress("factories")).
                namedAddress("memberFactory");

        MemberFactory(memFactory).createNew(_name, msg.sender);
        address member = MemberFactory(memFactory).last();
        AddressRegistrar(metaRegistrar.namedAddress("members")).
            add(_name, member, false);
        // Register by owner lookup also
        AddressRegistrar(metaRegistrar.namedAddress("members")).
            add(sha3(msg.sender), member, false);
    }

    function newMatter(bytes32 _name, string _url)
        public
    {
        address matFactory = AddressRegistrar(
            metaRegistrar.namedAddress("factories")).
                namedAddress("matterFactory");

        MatterFactory(matFactory).createNew(_name, _url);
        address matter = MatterFactory(matFactory).last();
        AddressRegistrar(metaRegistrar.namedAddress("matters")).
            add(_name, matter, false);
    }
    

    function newRegistrar(bytes32 _name, bool _overwrite)
        public
    {
        bootstrap.createNew();
        metaRegistrar.add(_name, bootstrap.last(), _overwrite);
    }
    
    function setRegistrarEntry(
        bytes32 _registrar, bytes32 _name, address _addr, bool _overwrite)
        public
    {
        address registrar = metaRegistrar.namedAddress(_registrar);
        AddressRegistrar(registrar).add(_name, _addr, _overwrite);
    }
    
}

contract EthenianDAOFactory
{
    string constant public VERSION = "EthenianDAOFactory 0.0.4-alpha";
    EthenianDAO public last;
    event Created(bytes32 _name, address _addr);

    function createNew(bytes32 _name)
        public
    {
        last = new EthenianDAO(_name, msg.sender);
        Created(_name, last);
    }
}
