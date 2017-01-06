import "./Matter.html";

Template.Matter.helpers ({
	name: function() {
		return web3.toAscii(currentMatter.get().name());
	},
	currentMatter: function() {
		return currentMatter.get();
	},
	currentMember: function() {
		return currentMember.get();
	},
})

Template.Matter.events({
	"click #findMatter": function(event) {
		currentReg.set("matters");
		modalCB.set(function(obj){
			currentMatter.set(contracts.matterContract.at(obj.address));
			console.log("Matter selected:", currentMatter.get());
			EthElements.Modal.show('Options');
		})
		EthElements.Modal.show('AddressRegistrar');
	},

	'click #newMatter': function() {
		EthElements.Modal.show('NewMatter');
	},
	"click #openVoting": function() {
		EthElements.Modal.show('Options');
	},
	"click #delegates": function(event) {
		EthElements.Modal.show('Delegates');
		// // currentReg.set("members");
		// // modalCB.set(function(obj){
		// // 	currentDelegate.set(contracts.memberContract.at(obj.address));
		// // 	EthElements.Modal.show('Delegate');

		// // })
		// EthElements.Modal.show('AddressRegistrar');
		// currentMatter.set(contracts.matterContract.at(currentDAO.get().getMatter(name)));
	},
})

Template.NewMatter.events({
	"submit form"(event, t) {
		event.preventDefault();
		var text = event.target.matterName.value;
		var url = event.target.resourceURL.value;
		console.log(text,url);

		currentDAO.get().newMatter(text,url, {from:ethAccount.get().address, gas:3000000}, function(e, tx) {
				console.log(e, tx);
				matterAddress = currentDAO.get().getMatter(text);
				currentMatter.set(contracts["matterContract"].at(matterAddress));
				EthElements.Modal.show('Options')});
	},

})
