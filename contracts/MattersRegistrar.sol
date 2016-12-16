/******************************************************************************\

file:   MattersRegistrar.sol
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

import "Registrar.sol";
import "Matter.sol";

pragma solidity ^0.4.0;

contract MattersRegistrar is Registrar
{
    string constant public VERSION = "MattersRegistrar 0.0.1-alpha";

    modifier onlyRaiser () {
        // TODO validate user permission
        _;
    }
    
    function get(uint _index)
        public
        constant
        returns (Matter)
    {
        return Matter(getIntl(_index));
    }

    function newMatter(string _description)
        external
        onlyOwner
        canEnter
        returns (Matter matter_)
    {
        matter_ = MatterFactory(factory).createNew(owner, size, _description);
        addIntl(uint(matter_));
        return;
    }
    
}