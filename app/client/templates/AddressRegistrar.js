import "./AddressRegistrar.html";

Template.AddressRegistrar.helpers({
	title: function () {
		var metaReg = contracts['addressRegistrarContract'].at(currentDAO.get().metaRegistrar());
		var reg = contracts['addressRegistrarContract'].at(metaReg.namedAddress(currentReg.get()));
		return web3.toAscii(reg.idName(0));
	},
	entries: function () {

		var metaReg = contracts['addressRegistrarContract'].at(currentDAO.get().metaRegistrar());
		var reg = contracts['addressRegistrarContract'].at(metaReg.namedAddress(currentReg.get()));
		var size = reg.size();
		var ret = [];
		for (var i=0; i < size; i++){
			var name = web3.toAscii(reg.idName(i));
			var addr = reg.idAddress(i);
			ret.push({name: name, address: addr});
		}
		return ret;
	},
})

Template.AddressRegistrar.events({
	'click .regEntry': function() {
		lastRegEntry.set(this);
		EthElements.Modal.hide();
		modalCB.get()(this);	
	}
})