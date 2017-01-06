/******************************************************************************\

file:   DAOAccount.sol
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

pragma solidity ^0.4.0;

import "Base.sol";
import "Interfaces.sol";
import "Matter.sol";

contract DAOAccount is Base //, DAOAccountInterface
{

/* Constants */

    string constant public VERSION = "DAOAccount 0.0.3-alpha";

    EthenianDAOInterface public dao;
    uint public lastActiveBlock;
    uint public lastActiveBalance;
    uint public fundedCredits;
    bytes8 public permissions;

    modifier touch()
    {
        lastActiveBlock = block.number;
        _;
    }

    modifier onlyDAO ()
    {
        if (msg.sender != address(dao)) throw;
        _;
    }
    
    function DAOAccount(address _dao, address _externalOwner)
        public
    {
        dao = EthenianDAOInterface(_dao);
        owner = _externalOwner;
        lastActiveBlock = block.number;
    }
    
    function ()
        payable
        touch
    {
        lastActiveBalance = this.balance;
    }
    
    function changePermissions(bytes8 _permissions)
        external
        onlyDAO
        canEnter
    {
        permissions = _permissions;
    }
    
    function fundMatter(bytes32 _matterName, uint _amount)
        external
        onlyOwner
        canEnter
        touch
    {
        fundedCredits += _amount;
        MatterInterface matter = MatterInterface(dao.getMatter(_matterName));
        if(!matter.fund(_amount)) throw;
    }
}


contract DAOAccountFactory
{
    event Created(address _addr);
    DAOAccount public last;

    function createNew(address _dao, address _owner)
        public
    {
        last = new DAOAccount(_dao, _owner);
        Created(last);
    }
}