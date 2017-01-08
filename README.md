#The EthenianDAO - POC 1 "SandleStraps"

The Ethenian Decentralized Autonamous Organisation is a framework of smart contracts written for the Etherium platform.  It's primary focus is to offer direct and delegative democratic governance models for a broad range of organisational types.  This framework utilises a system of registrars and smart contract factories to offer extensibility and upgradeability while offering secure management of stakeholder funds.

In the EthenianDAO, Member's raise, vote, and fund Matters.  Each member owns and funds their own member contract and maintains full control over those funds until they are committed to funding a Matter.  A member's voting power is proportional to their level of financial commitment up to an optional maximum voting balance.

##Release Notes
This code base is an early Proof of Concept, it is neither complete nor algorithmically secure but has been released here as an entry into the [Blockchain Virtual UAE GovHack](http://blockchainvirtualgovhack.com/) hackathon.


## Running
![EthenianDAO Screenshot](voting.png)
This repository is in no way ready for deploying to a blockchain and user friendly deployment has not yet been developed.  For development purposes [Browser Solidity, as a chrome extension](https://github.com/ethereum/browser-solidity) can connect to a local instance of [testrpc](https://github.com/ethereumjs/testrpc) for simulating the blockchain environment.  The front end has been written for [Meteor](https://www.meteor.com/) for later integration into Ethereum Mist and can be run under a different tab by launching Meteor in the `app` directory.

* Load up the solidity files in Browser Solidity and compile `EthenianDAO` (solc version 4.7 has been used in development).
* Launch `testrpc` and connect Browser Solidity to the Web3 Provider.
* `Create` the `EthenianDAOFactory` and use the `createNew` function with an optional name to create a DAO contract 
* The `last` function will supply the address of the DAO contract.  Copy this address into the `At Address` field of the `EthenianDAO` contract.
* This address also has to be pasted against `daoAddr` in `app/client/main.js` (as routing is not yet implimented)
* Click on functions `init1` then `init2`.
	* Create `MemberFactory` and copy it's address.
* Launch `Meteor` from the `app` directory and point a browser to `localhost:3000`. You should now see the GUI
* Click `Add Factory` and enter `memberFactory` as the name and paste the `MemberFactory` address.
* Repeat for `Matter Factory`
* You should now be able to `Join this DAO` and then `Raise a Matter`. 
* NOTE: Only one member account is allowed per Etherium account.
* Click `Fund Member Account` to send funds.  Voting power is proportional to funds provided.
* Once a matter is created, options and delegates can be added.
* A member can adjust the sliders on the options and delegates of a matter to express preferences between 0 to 100% of their voting power and then click `Submit Votes`

A number of reserved name matters will be recognised by the EthenianDAO. Raising matters named `minimumVoteBalance` and `maximumVoteBalance` will allow members to vote on these levels.  Such *scalar* return a average of the values which have been voted for.

Again this project is in early development and runs poorly.  If you find it interesting none-the-less or would like to contributes, please let me know. If you have front end skills particularly with Meteor, then I'd certainly love to hear from you.



