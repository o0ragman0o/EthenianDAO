/******************************************************************************\

file:   Matter.sol
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

pragma solidity ^0.4.0;


contract Matter is Base
{
    string constant public VERSION = "Matter 0.0.4-alpha";
    bool constant CLOSED = false;
    bool constant OPEN = true;
    
    struct Option {
        // voter -> tokens -> voting power
        bool open;
        uint value;
        uint votes;
        bytes32 name;
        address recipient;
    }
    
    bool public open;
    bool public recurrent;
    bool public scalar;
    bool public tendering;
    bool public funding;
    bool public refunding;
    address public dao;
    bytes32 public name;
    uint public numOptions;
    uint public votesCast;
    uint public openTimeStamp;
    uint public period;
    uint public periods;
    mapping (uint => Option) public options;
    // voter -> optionId -> votes
    mapping (address => mapping (uint => uint)) public voters;

    modifier onlyVoters()
    {
        // TODO validate caller through MembersRegistrar
        _;
    }
    
    modifier onlyTenders()
    {
        // TODO validate tender through MembersRegistrar
        _;
    }
    
    modifier isFunding
    {
        // TODO funding validations
        _;
    }
    
    modifier optionOpen(uint _optionId)
    {
        if (!options[_optionId].open) throw;
        _;
    }
    
    modifier votingOpen()
    {
        // if (block.timestamp > openTimeStamp + period) {
        //     if (recurrent) {
        //         openTimeStamp = block.timestamp;
        //         periods++;
        //     } else {
        //         open = CLOSED;
        //     }
        // }
        // if (!open) throw;
        _;
    }

/* Constant Functions */

    function value()
        public
        constant
        returns (uint value_)
    {
        value_ = scalar ? average() : options[leader()].value;
    }
    
    function average()
        public
        constant
        returns (uint average_)
    {
        if (votesCast == 0) return 0;
        uint total;
        for(uint i = 0; i <= numOptions; i++) {
            total += options[i].value * options[i].votes;
        }
        average_ = total / votesCast;
    }
    
    function leader()
        public
        constant
        returns (uint leader_)
    {
        uint curLeader = 0;
        for(uint i = 1; i <= numOptions; i++) {
            // TODO - ! fix order biased on ties.
            curLeader = options[curLeader].votes < options[i].votes ?
                i : curLeader;
        } 
       leader_ = curLeader;
    }
        

/* External and Public functions */

    function Matter(address _dao, bytes32 _name, string _url)//, bool _scalar)
    {
        dao = _dao;
        name = _name;
        resourceURL = _url;
        open = OPEN;
        votesCast = 1;
        // scalar = _scalar;
    }
    
    function touch() {
        
    }

    function vote(uint _optionId, uint _votes)
        external
        onlyVoters
        canEnter
        votingOpen
        optionOpen(_optionId)
    {
        options[_optionId].votes += _votes;
        votesCast += _votes;
    }
    
    function addOption(bytes32 _name, uint _value, address _recipient)
        external
        onlyTenders
        canEnter
    {
        options[numOptions].name = _name;
        options[numOptions].value = _value;
        // options[numOptions].votes = 1; // Prevents div0 on averaging
        options[numOptions].recipient = _recipient;
        options[numOptions].open = true;
        // votesCast++;
        numOptions++;
    }
    
    function fund(uint _amount)
        payable
        isFunding
        canEnter
    {
    }
}


contract MatterFactory
{
    string constant public VERSION = "MatterFactory 0.0.4-alpha";
    Matter public last;
    event Created(bytes32 _name, address _addr);

    function createNew(bytes32 _name, string _url)//, bool _scalar)
        public
    {
        last = new Matter(msg.sender, _name, _url);//, _scalar);
        Created(_name, last);
    }
}


