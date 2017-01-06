if(typeof web3 === 'undefined')
	web3 = new Web3(new Web3.providers.HttpProvider('http://localhost:8545'));

// get the latest block
// web3.eth.filter('latest').watch(function(e, blockHash) {
// 	ittDict["latestBlock"].set(web3.eth.blockNumber);
// 	ittAPI.updateDesk();
	// if(!e) {
	// 	web3.eth.getBlock(blockHash, function(e, block){
	// 		ittDict["latestBlock"].set(block);
	// 	});
	// }
// });

EthAccounts.init();
EthBlocks.init();

contracts = new Object();
deployed = new Object();
deploy = new Object();

