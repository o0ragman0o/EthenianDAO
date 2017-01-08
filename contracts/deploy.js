fs = require('fs');
Web3 = require('web3');

TestRPC = require("ethereumjs-testrpc");

web3 = new Web3();
web3.setProvider(TestRPC.provider());


solcJSON = JSON.parse(fs.readFileSync('build/EthenianDAO.json', 'utf8'));
solcVersion = solcJSON['version'];
contracts = {};
deployed = {};
admin = web3.eth.contract(solcJSON.contracts[Member].abi);
pass = true;
outToLunch = 0;

deployOrder = {
	"EthenianDAO":{},
	"Authority":{},
	"MemberFactory":{},
	"MembersRegistrar":{},
	"MatterFactory":{},
	"MattersRegistrar":{}
};

bootstrap = function () {

}

step1 = function() {
	outToLunch = size(deployOrder);
	console.log("Preparing contracts.");
	if(!prepContracts()) return false;
	console.log("Deploying contracts.");
	for (c in deployOrder) {
		console.log("Deploying " + c)
		if(!deployer(contracts[c], deployOrder[c])) return false;
		outToLunch--;
	}
	while (outToLunch) sleep(0.5);
}

step2 = function () {
	console.log("Setting factory addresses in registrars");
	outToLunch = 2;
	if(!MembersRegistrar.setFactory(deployed.MemberFactory.address, {from:web3.eth.coinbase},
		function(e, contract) {
			if (MembersRegistrar.factory() === deployed.MemberFactory.address) {
				console.log("success: MembersRegistrar factory at ", deployed.MemberFactory.address);
				outToLunch--;
			} else {
				console.log("error: Failed to set MembersRegistry factory to ", deployed.MemberFactory.address);
				return false;
			}
		})
	) return false;

	if(!MattersRegistrar.setFactory(deployed.MatterFactory.address, {from:web3.eth.coinbase}),
		function(e, contract) {
			if (MattersRegistrar.factory() === deployed.MatterFactory.address) {
				console.log("success: MembersRegistrar factory at ", deployed.MatterFactory.address);
				outToLunch--;
			} else {
				console.log("error: Failed to set MembersRegistry factory to ", deployed.MatterFactory.address);
				return false;
			}
		})
	) return false;
	
	while (outToLunch) sleep(0.5);
	return true;
}

step2 = function () {
	outToLunch = 2;
	console("Chaning ownership of registrars to EthenianDAO");
	if(!MembersRegistrar.changeOwner(deployed.EthenianDAO.address, {from:web3.eth.coinbase}),
		function(e, contract) {
			if (MembersRegistrar.owner() === deployed.EthenianDAO.address) {
				console.log("success: MembersRegistrar owner at ", deployed.Ethenian.address);
				outToLunch--;
			} else {
				console.log("error: Failed to set MembersRegistry owner to ", deployed.MemberFactory.address);
				return false;
			}
		})
	) return false;

	if(!MattersRegistrar.changeOwner(deployed.EthenianDAO.address, {from:web3.eth.coinbase}),
		function(e, contract) {
			if (MattersRegistrar.owner() === deployed.EthenianDAO.address) {
				console.log("success: MattersRegistrar factory at ", deployed.EthenianDAO.address);
				outToLunch--;
			} else {
				console.log("error: Failed to set MattersRegistry owner to ", deployed.EthenianDAO.address);
				return false;
			}
		})
	) return false;

	while (outToLunch) sleep(0.5);
	return true;
}

step3 = function () {
	outToLunch = 3;
	console.log("Linking contracts into EthenianDAO.");
	if(!EthenianDAO.setContract("membersRegistrar",deployed.MembersRegistrar.address, {from:web3.eth.coinbase}),
		function(e, contract) {
			if (MembersRegistrar.owner() === deployed.EthenianDAO.address) {
				console.log("success: MembersRegistrar owner at ", deployed.Ethenian.address);
				outToLunch--;
			} else {
				console.log("error: Failed to set MembersRegistry owner to ", deployed.MemberFactory.address);
				return false;
			}
		})
	) return false;

	if(!EthenianDAO.setContract("mattersRegistrar",deployed.MattersRegistrar.address, {from:web3.eth.coinbase}),
		function(e, contract) {
			if (MattersRegistrar.owner() === deployed.EthenianDAO.address) {
				console.log("success: MattersRegistrar factory at ", deployed.EthenianDAO.address);
				outToLunch--;
			} else {
				console.log("error: Failed to set MattersRegistry owner to ", deployed.EthenianDAO.address);
				return false;
			}
		})
	) return false;

	if(!EthenianDAO.setContract("authority",deployed.Authority.address, {from:web3.eth.coinbase}),
		function(e, contract) {
			if (MattersRegistrar.owner() === deployed.EthenianDAO.address) {
				console.log("success: MattersRegistrar factory at ", deployed.EthenianDAO.address);
				outToLunch--;
			} else {
				console.log("error: Failed to set MattersRegistry owner to ", deployed.EthenianDAO.address);
				return false;
			}
		})
	) return false;
	while (outToLunch) sleep(0.5);
	return true;
}

step = function() {
	outToLunch = 1;
	console.log("Creating admin member.");
	admin.at(EthenianDAO.newMember("admin", {from:web3.eth.coinbase},
		function(e, contract) {
			adminAddr = EthenianDAO.getMember("admin");
			if (adminAddr) {
				console.log("success: Admin member contract at ", adminAddr);
				outToLunch--;
			} else {
				console.log("error: Failed to create Admin member contract.");
				return false;
			}
		})
	);
	while (outToLunch) sleep(0.5);	
}


step = function() {
	outToLunch = 3;
	console.log("Raising administrative matters.");
	admin.raiseMatter("maximumVoteBalance", {from:web3.eth.coinbase},
		function(e, contract) {
			maximumVoteBalance = EthenianDAO.getContract("maximumVoteBalance");
			if (maximumVoteBalance) {
				console.log("success: maximumVoteBalance contract at ", maximumVoteBalance);
				outToLunch--;
			} else {
				console.log("error: Failed to create maximumVoteBalance contract.");
				return false;
			}
		})
	);
	admin.raiseMatter("attritionTaxRate", {from:web3.eth.coinbase},
		function(e, contract) {
			attritionTaxRate = EthenianDAO.getContract("attritionTaxRate");
			if (attritionTaxRate) {
				console.log("success: attritionTaxRate contract at ", attritionTaxRate);
				outToLunch--;
			} else {
				console.log("error: Failed to create attritionTaxRate contract.");
				return false;
			}
		})
	);
	admin.raiseMatter("withdrawalTaxBlocks", {from:web3.eth.coinbase},
		function(e, contract) {
			maximumVoteBalance = EthenianDAO.getContract("maximumVoteBalance");
			if (adminAddr) {
				console.log("success: maximumVoteBalance contract at ", maximumVoteBalance);
				outToLunch--;
			} else {
				console.log("error: Failed to create maximumVoteBalance contract.");
				return false;
			}
		})
	);


prepContracts = function() {

	console.log("solc version: ", solcVersion);
	for (c in solcJSON['contracts']) {
		contracts[c] = web3.eth.contract(solcJSON.contracts[c].abi);
		contracts[c].bin = solcJSON.contracts[c].bin;
		console.log(c, contracts[c]);
	}
}

deployer = function(name, args) {
	deployed[name] = contracts[name].new(
		args,
		{
		 from: web3.eth.accounts[0], 
		 data: contracts[name].bin,
		 gas: '4700000'
		}, function (e, contract){
		console.log(e, contract);
		if (typeof contract.address !== 'undefined') {
		     console.log('success: ' + name + ' deployed at address: ' + contract.address + ' transactionHash: ' + contract.transactionHash);
		     return true;
		} else {
			console.log('error: Failed to deploy' + name + '!')
			return false;
		}
}


buildDAO = function() {

	for (c in buildOrder) {
		buildOrder[c];
	}
}

size = function(obj) {
    var size = 0, key;
    for (key in obj) {
        if (obj.hasOwnProperty(key)) size++;
    }
    return size;
};
