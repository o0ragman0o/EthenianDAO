/******************************************************************************\

file:   Registrar.sol
ver:    0.0.1-alpha
updated:16-Dec-2016
author: Darryl Morris (o0ragman0o)
email:  o0ragman0o AT gmail.com

This file is part of the Ethenian DAO framework.

A Registrar maintains an address registry of contracts produced by a factory

This software is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
See MIT Licence for further details.
<https://opensource.org/licenses/MIT>.

\******************************************************************************/

pragma solidity ^0.4.0;

import "Base.sol";
import "BidirectionalLUT.sol";

contract Registrar is Base, BidirectionalLUT
{
    string constant public VERSION = "Registrar 0.0.1-alpha";

    address public factory;

    function setFactory(address _factory)
        public
        onlyOwner
        canEnter
        returns (bool)
    {
        factory = _factory;
        return SUCCESS;
    }

}
