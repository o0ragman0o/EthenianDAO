import { Template } from 'meteor/templating';
import { ReactiveVar } from 'meteor/reactive-var';

import './main.html';

function handleError(e) {
	console.log(e);
}

daoAddr = "0xd0719067cc351e028d3dae14d8e93fe8ba030665";
daoFactory = contracts["ethenianDAOFactoryContract"].at("0x3b3d3de7a3271f0f6bea0b6b99e6f26a64dd3617");
currentReg = new ReactiveVar();
lastRegEntry = new ReactiveVar();
modalCB = new ReactiveVar();
currentMember = new ReactiveVar();
currentDelegate = new ReactiveVar();
currentMatter = new ReactiveVar();
currentDAO = new ReactiveVar();

if (daoAddr) {
	currentDAO.set(contracts["ethenianDAOContract"].at(daoAddr))
	memberAddress = currentDAO.get().getMemberFromOwner(EthAccounts.findOne().address);
	if(memberAddress != 0)
		currentMember.set(contracts["memberContract"].at(memberAddress));
} else {
	deploy["deployNewEthenianDAO"]();
}



