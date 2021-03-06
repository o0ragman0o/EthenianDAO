/******************************************************************************\

file:   Base.sol
ver:    0.2.5
updated:6-Jan-2017
author: Darryl Morris (o0ragman0o)
email:  o0ragman0o AT gmail.com

An base contract furnishing inheriting contracts with ownership, reentry
protection and safe sending functions.

This software is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
See MIT Licence for further details.
<https://opensource.org/licenses/MIT>.

\******************************************************************************/


pragma solidity ^0.4.0;

contract Base
{
/* Constants */

    string constant public VERSION = "Base 0.2.5";

/* State Variables */

    bool mutex;
    address public owner;
    string public resourceURL;

/* Events */

    event Log(string message);
    event ChangedOwner(address indexed oldOwner, address indexed newOwner);

/* Modifiers */

    // To throw call not made by owner
    modifier onlyOwner() {
        if (msg.sender != owner) throw;
        _;
    }

    // This modifier can be used on functions with external calls to
    // prevent reentry attacks.
    // Constraints:
    //   Protected functions must have only one point of exit.
    //   Protected functions cannot use the `return` keyword
    //   Protected functions return values must be through return parameters.
    modifier preventReentry() {
        if (mutex) throw;
        else mutex = true;
        _;
        delete mutex;
        return;
    }

    // This modifier can be applied to pulic access state mutation functions
    // to protect against reentry if a `mutextProtect` function is already
    // on the call stack.
    modifier noReentry() {
        if (mutex) throw;
        _;
    }

    // Same as noReentry() but intended to be overloaded
    modifier canEnter() {
        if (mutex) throw;
        _;
    }
    
    modifier hasEther(uint _amount) {
        if (_amount > this.balance) throw;
        _;
    }
    
/* Functions */

    function Base() { owner = msg.sender; }

    function contractBalance() public constant returns(uint) {
        return this.balance;
    }

    // Change the owner of a contract
    function changeOwner(address _newOwner)
        public onlyOwner
    {
        owner = _newOwner;
        ChangedOwner(msg.sender, owner);
    }
    
    function setResourceURL(string _res)
        public onlyOwner
    {
        resourceURL = _res;
    }
    
    function safeSend(address _recipient, uint _ether)
        internal
        preventReentry()
    {
        if(!_recipient.call.value(_ether)()) throw;
    }
}

/* End of Base */