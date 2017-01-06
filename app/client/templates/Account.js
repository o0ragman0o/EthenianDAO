import "./Account.html";


Template.EthereumAccount.onCreated(function () { 
	ethAccount = new ReactiveVar(EthAccounts.findOne());
	// TemplateVar.set("ethAccount", EthAccounts.findOne());
})

Template.EthereumAccount.helpers({
	ethAccount: function () {
		return ethAccount.get();
	}
})

Template.EthereumAccount.events({
	'click button.modal': function(){
		EthElements.Modal.show('AccountList');
	},
})

Template.AccountList.onCreated(function () {
	TemplateVar.set("ethAccounts", EthAccounts.find().fetch())
})

Template.AccountList.events({
	'click button.accButton': function(e, template){
		ethAccount.set(this);
		memberAddress = currentDAO.get().getMemberFromOwner(this.address);
		if(memberAddress != 0) {
			currentMember.set(contracts["memberContract"].at(memberAddress));
		} else {
			currentMember.set();
		}
		EthElements.Modal.hide();
	},
})