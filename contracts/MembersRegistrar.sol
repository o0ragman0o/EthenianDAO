/******************************************************************************\

file:   MembersRegistrar.sol
ver:    0.0.1-alpha
updated:16-Dec-2016
author: Darryl Morris (o0ragman0o)
email:  o0ragman0o AT gmail.com

This file is part of the Ethenian DAO framework

The Members Registrar is the container for EthenianDAO member addresses and
the factory contract that creates member contracts.

This software is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
See MIT Licence for further details.
<https://opensource.org/licenses/MIT>.

\******************************************************************************/

pragma solidity ^0.4.0;

import "Registrar.sol";
import "Member.sol";


contract MembersRegistrar is Registrar
{
    string constant public VERSION = "MembersRegistrar 0.0.1-alpha";


    modifier onlyRecruiter () {
        // TODO validate user permission
        _;
    }
    
    function newMember(string _name, address _externalOwner)
        external
        onlyOwner
        canEnter
        returns (Member member_)
    {
        member_ = MemberFactory(factory).createNew(owner, _name, _externalOwner);
        addIntl(uint(member_));
        return;
    }
}