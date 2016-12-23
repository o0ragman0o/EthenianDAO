/******************************************************************************\

file:   AddressesRegistrar.sol
ver:    0.0.3-alpha
updated:21-Dec-2016
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
    mapping (uint => bytes32) public idName;

    modifier canUpdate(bytes32 _name, bool _overwrite)
    {
        if (!_overwrite && namedAddress[_name] != 0x0) throw;
        _;
    }

    function add(bytes32 _name, address _addr, bool _overwrite)
        public
        onlyOwner
        returns (uint id_)
    {
        size++;
        namedAddress[_name] = _addr;
        addressId[_addr] = size;
        idName[size] = _name;    
        id_ = size;
    }
    
    function remove(bytes32 _name)
        public
        onlyOwner
        returns (bool)
    {
        delete idName[addressId[namedAddress[_name]]];
        delete addressId[namedAddress[_name]];
        delete namedAddress[_name];
        return SUCCESS;
    }
    
    function idAddress(uint _id)
        public
        constant
        returns (address addr_)
    {
        addr_ = namedAddress[idName[_id]];
        return;
    }

    function getName(address _addr)
        public
        constant
        returns (string)
    {
        uint name = uint(idName[addressId[_addr]]);
        bytes memory bytesString = new bytes(32);
        for (uint j=0; j<32; j++) {
            byte char = byte(bytes32(name * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[j] = char;
            }
        }
        return string(bytesString);
    }
}