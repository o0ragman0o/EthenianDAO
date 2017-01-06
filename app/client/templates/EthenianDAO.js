import "./EthenianDAO.html";

Template.EthenianDAO.onCreated(function() {
	// currentDAO = new ReactiveVar(deployed["ethenianDAO"].
	// 	at(currentDAOAddress.get()));
})

Template.EthenianDAO.helpers({
	name: function() {
		return web3.toAscii(currentDAO.get().name());
	},
	currentDAO: function () {
		return currentDAO.get();
	},
	currentMember: function() {
		return currentMember.get();
	},
	admin: function() {
		return ethAccount.get().address == currentDAO.get().owner();
	}
})

Template.EthenianDAO.events({
	"submit .newMember": function(event) {
		event.preventDefault();
		const target = event.target;
		const name = target.newName.value;
		currentDAO.get().newMember(name,{from:ethAccount.get().address, gas:3000000})
		console.log(target.newName.value);
		// currentDAO.get().newMember()
	},
	"click .newReg": function (event) {
		EthElements.Modal.show({
			template: "NewRegistrar",
			ok: function(event){
				console.log(event.target);
		    }
		})
	},
	"click .addFactory": function (event) {
		EthElements.Modal.show({
			template: "AddFactory",
			ok: function(event){
				console.log(event.target);
		    }
		})
	},
})

Template.NewRegistrar.events({
	"submit form": function(event, t) {
		event.preventDefault();
		var text = t.$('#regName')[0].value;
		console.log(text);

		currentDAO.get().newRegistrar(text, {from:ethAccount.get().address, gas:1000000}, function() {EthElements.Modal.hide()});
	}
})

Template.AddFactory.events({
	"submit form": function(event, t) {
		event.preventDefault();
		target = event.target;
		var name = target[0].value;
		var address = target[1].value;
		console.log(name,address);

		currentDAO.get().setRegistrarEntry("factories", name, address, true,
			{from:ethAccount.get().address, gas:1000000}, function(e) {
				console.log(e);
				EthElements.Modal.hide()});
	}
})

