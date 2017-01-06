import "./FundAccount.html";

Template.FundAccount.helpers ({
	name: function() {
		return web3.toAscii(currentMember.get().name());
	},
	currentMember: function () {
		return currentMember.get();
	}
})

Template.FundAccount.events ({
	'submit #sendFunds'(event) {
		event.preventDefault();
		const amount = event.target.sendAmount.value;
		web3.eth.sendTransaction({to:currentMember.get().address, from:ethAccount.get().address, value:amount, gas:200000},
			function (e) {
				console.log(e, {amount:amount,from:ethAccount.get().address,to:currentMember.get().address});
				// memberAddress = currentDAO.get().getMemberFromOwner(ethAccount.get().address);
				currentMember.set(currentMember.get());
				EthElements.Modal.hide();
			}
		)
	}
})