/******************************************************************************\

file:   AddressesRegistrar.sol
ver:    0.0.5-sandalstraps
updated:6-Jan-2017
author: Darryl Morris (o0ragman0o)
email:  o0ragman0o AT gmail.com



This software is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
See MIT Licence for further details.
<https://opensource.org/licenses/MIT>.

\******************************************************************************/

pragma solidity ^0.4.0;

import "Base.sol";

contract AddressRegistrar is Base
{
    string constant public VERSION = "AddressRegistrar v0.0.3-alpha";
    
    uint public size = 0;
    // name -> address -> id -> name
    mapping (bytes32 => address) public namedAddress;
    mapping (address => uint) public addressId;
    // TODO Redundant store. maybe refer to name in contract
    mapping (uint => bytes32) public idName;

    modifier canUpdate(bytes32 _name, bool _overwrite)
    {
        if (!_overwrite && namedAddress[_name] != 0x0) throw;
        _;
    }
    
    event Entered(bytes32 name, address addr);

    function AddressRegistrar(address _owner)
        public
    {
        owner = _owner;
    }
    
    function add(bytes32 _name, address _addr, bool _overwrite)
        public
        onlyOwner
        canUpdate(_name, _overwrite)
    {
        namedAddress[_name] = _addr;
        addressId[_addr] = size;
        idName[size] = _name;    
        size++;
    }
    
    function remove(bytes32 _name)
        public
        onlyOwner
    {
        delete idName[addressId[namedAddress[_name]]];
        delete addressId[namedAddress[_name]];
        delete namedAddress[_name];
    }
    
    function idAddress(uint _id)
        public
        constant
        returns (address addr_)
    {
        addr_ = namedAddress[idName[_id]];
        return;
    }
}

contract AddressRegistrarFactory
{
    string constant public VERSION = "AddressRegistrarFactory v0.0.4-alpha";
    AddressRegistrar public last;

    event Created(address _addr);
    
    function createNew()
        public
    {
        last = new AddressRegistrar(msg.sender);
        Created(last);
    }
}
