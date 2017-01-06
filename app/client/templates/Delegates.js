import "./Delegates.html";

Template.Delegates.helpers({
	matterName: function () {
		return web3.toAscii(currentMatter.get().name());
	},
	delegates: function () {
		var matterName = currentMatter.get().name();
		var dlgtAddrs = currentMember.get().getDelegatesFor(matterName);
		delegates = [];
		for(var i=0; i < dlgtAddrs.length; i++) {
			var dlgt = contracts["memberContract"].at(dlgtAddrs[i])
			delegates.push({
				name: web3.toAscii(dlgt.name()),
				address: dlgt.address,
				tokens: dlgt.constituents(matterName, currentMember.get().address)[0],
			});
		}
		TemplateVar.set("delegates", delegates);
		return delegates;
	},
})

Template.Delegates.events({
	'click #addDelegate': function() {
		currentReg.set("members");
		modalCB.set(function(obj){
			// var dlgts = TemplateVar.get("delegates");
			// dlgts.push(obj);
			// TemplateVar.set("delegates",dlgts);
			// EthElements.Modal.show('Delegates');
			// currentDelegate.set(contracts.memberContract.at(obj.address));

			currentMember.get().delegateVotesTo(
				currentMatter.get().name(),
				obj.name,
				0,
	            // obj.tokens,
	            {from:ethAccount.get().address, gas:200000},
				function () {
					EthElements.Modal.show('Delegates');
				})
		});
		EthElements.Modal.show('AddressRegistrar')
	},

	'submit form' (event, tlpt) {
		event.preventDefault();
		targ = event.target;
		dlgts = TemplateVar.get("delegates");
		for(var i=0; i < dlgts.length; i++){
			var v = Number(targ[i].value);
			console.log("delegated", v,"% to ", dlgts[i].name);
			currentMember.get().delegateVotesTo(
				currentMatter.get().name(),
				dlgts[i].name,
				v,
	            {from:ethAccount.get().address, gas:200000})
		}
		EthElements.Modal.hide();
	},
})


