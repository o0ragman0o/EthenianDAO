/******************************************************************************\

file:   EthenianDAO.sol
ver:    0.0.6
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

import "Interfaces.sol";
import "SandalStraps.sol";
import "Matter.sol";
import "Member.sol";
import "Authority.sol";
import "Registrar.sol";


pragma solidity ^0.4.0;

contract EthenianDAO is SandalStraps
{
    string constant public VERSION = "EthenianDAO v0.0.6";

/* EthenianDAO Standard public functions */

    function EthenianDAO(address _creator, bytes32 _regName, address _owner)
        public
        SandalStraps(_creator, _regName, _owner)
    {
        // owner = _owner;
        // regName = _regName;
    }

    // Returns the attritian tax rate per block
    function attritionTaxRate()
        public
        constant
        returns (uint aTR_)
    {
        address matReg = Registrar(
            metaRegistrar.namedAddress("Matters")).
                namedAddress("attritionTaxRate");
        aTR_ = matReg == 0x0 ?
            0 : MatterInterface(matReg).value();
    }
    
    function withdrawalTaxRate()
        public
        constant
        returns (uint wTR_)
    {
        address matReg = Registrar(
            metaRegistrar.namedAddress("Matters")).
                namedAddress("withdrawlTaxRate");
        wTR_ = matReg == 0x0 ?
            0 : Value(matReg).value();
    }
    
    function minimumVoteBalance()
        public
        constant
        returns (uint minVB_)
    {
        address matReg = Registrar(
            metaRegistrar.namedAddress("Matters")).
                namedAddress("minimumVoteBalance");
        minVB_ = matReg == 0x0 ?
            0 : Value(matReg).value();
    }
    
    function maximumVoteBalance()
        public
        constant
        returns (uint maxVB_)
    {
        address matReg = Registrar(
            metaRegistrar.namedAddress("Matters")).
                namedAddress("maximumVoteBalance");
        maxVB_ = matReg == 0x0 ?
            uint(-1) : Value(matReg).value();
    }
    
    function getMatter(bytes32 _name)
        public
        constant
        returns (address matter_)
    {
        matter_ = Registrar(
            metaRegistrar.namedAddress("Matters")).namedAddress(_name);
    }
    
    function getMember (bytes32 _name)
        public
        constant
        returns (address member_)
    {
        member_ = Registrar(
            metaRegistrar.namedAddress("Members")).namedAddress(_name);
    }

    function getMemberFromOwner (address ownerAddr_)
        public
        constant
        returns (address member_)
    {
        member_ = Registrar(
            metaRegistrar.namedAddress("Members")).
                namedAddress(sha3(ownerAddr_));
    }
    
    function authority()
        public
        constant
        returns (address auth_)
    {
        auth_ = metaRegistrar.namedAddress("Authority");
        return;
    }

/* Public non-constant Functions */ 

    // To boostrap the central registry post deployment

    function newMember(bytes32 _name)
        public
    {
        newFromFactory("Members", _name);
        // Register by owner lookup also.
        // TODO Consider seperate owners registrar
        // Registrar(metaRegistrar.namedAddress("Members")).
        //     add(sha3(msg.sender), getLastFromFactory("Members"));
    }
}

contract EthenianDAOFactory is FactoryInterface
{
    bytes32 constant public regName = "EthenianDAOs";
    string constant public VERSION = "EthenianDAOFactory v0.0.6";

    EthenianDAO public last;
    function createNew(bytes32 _regName, address _owner)
        public
    {
        last = new EthenianDAO(msg.sender, _regName, _owner);
        Created(msg.sender, _regName, last);
    }
}
