import "./Member.html";

Template.Member.helpers ({
	name: function() {
		return web3.toAscii(currentMember.get().name());
	},
	currentMember: function() {
		return currentMember.get();
	},
})

Template.Member.events ({
	'click #fundAccount': function(){
		EthElements.Modal.show('FundAccount');
	},
	'click #newMember': function(){
		EthElements.Modal.show('NewMember');
	}
})

Template.NewMember.events({
	"submit form": function(event, t) {
		event.preventDefault();
		var text = t.$('#memberName')[0].value;
		console.log(text);

		currentDAO.get().newMember(text, {from:ethAccount.get().address, gas:3000000}, function(e, tx) {
				console.log(e, tx);
				memberAddress = currentDAO.get().getMemberFromOwner(ethAccount.get().address);
				currentMember.set(contracts["memberContract"].at(memberAddress));
				EthElements.Modal.hide()});
	}

})
