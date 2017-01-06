import "./Option.html";

Template.Option.helpers({

})


Template.OptionForm.events({
	'submit form': function(event){
		event.preventDefault();		
		t = event.target;
		console.log(t.optionName.value, t.optionValue.value);
		currentMatter.get().addOption(t.optionName.value, t.optionValue.value, '0x0', {from:ethAccount.get().address, gas:300000}, 
			function(e,c){
				console.log(e,c);
				EthElements.Modal.show("Options");
			});
	}
})