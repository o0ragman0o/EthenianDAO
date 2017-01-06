import "./Options.html"

Template.Options.helpers({
	showSubmit: function() {
		return true;
	},
	currentMember: function() {
		return currentMember.get() != "undefined" ? true : false;
	},
	matterOptions: function() {
		var vote = currentMember.get().constituents(currentMatter.get().name(),currentMember.get().address);
		var opts = {};
		var o = [];
		var d = [];
		opts["member"] = currentMember.get();
		opts["votingTokens"] = vote[0].toNumber();
		opts["votes"] = vote[1].toNumber();
		opts["matter"] = currentMatter.get();
		opts["matterName"] = web3.toAscii(currentMatter.get().name());
		opts["numDelegates"] = opts["member"].numDelegates(opts["matterName"]);
		opts["numOptions"] = opts["matter"].numOptions().toNumber();
		opts["totalVotes"] = currentMember.get().totalVotes(opts["matterName"]).toNumber();
		for(var i=0; i < opts["numOptions"]; i++) {
			var opt = opts["matter"].options(i);
			var cv = opts["member"].currentVotes(opts["matterName"],i);
			o.push({
				index:i,
				name:web3.toAscii(opt[3]),
				open:opt[0],
				value:opt[1],
				votes:opt[2],
				recipient:o[4],
				ownTokens:cv[0],
				ownVotes:cv[1],
				lastValue:cv[0]});
		}
		var dlgtAddrs = currentMember.get().getDelegatesFor(opts["matterName"]);
		for(var i=0; i < dlgtAddrs.length; i++) {
			var dlgt = contracts["memberContract"].at(dlgtAddrs[i]);
			d.push({
				index: i + 'd',
				name: web3.toAscii(dlgt.name()),
				address: dlgt.address,
				tokens: dlgt.constituents(opts["matterName"], currentMember.get().address)[0],
				lastValue: dlgt.constituents(opts["matterName"], currentMember.get().address)[0]
			});
		}
		opts["options"] = o;
		opts["delegates"] = d;
		console.log(Template.instance());
		TemplateVar.set("matterOptions",opts);
		console.log(opts);
		return opts;
	},
})

Template.Options.events({
	'click #addOption': function () {
			EthElements.Modal.show('OptionForm');
	},
	'submit form' (event, template) {
		event.preventDefault();
		t = event.target;
		console.log(t);
		// var opts = template.opts.get();
		var opts = TemplateVar.get("matterOptions");
		for (var i=0; i < opts.numOptions; i++) {
			var opt = opts.options[i]
			if(opt.ownTokens != t[i].value) {
				console.log(opts.matterName, opt.name, t[i].value);
			}
		}
	},
	'click #addDelegate': function() {
		currentReg.set("members");
		modalCB.set(function(obj){
			currentMember.get().delegateVotesTo(
				currentMatter.get().name(),
				obj.name,
				0,
	            {from:ethAccount.get().address, gas:200000},
				function () {
					// TemplateVar.set("")
					EthElements.Modal.show('Options');
				})
		});
		EthElements.Modal.show('AddressRegistrar')
	},
	'change input': function (event, template) {
		tar = event.target;
		opts = TemplateVar.get("matterOptions");
		tot = opts.votingTokens;
		val = Number(tar.value);
		obj = tar.id.endsWith("d") ? opts.delegates[tar.id.slice(0,-1)] : opts.options[tar.id]
		lst = obj.lastValue;
		del = val - lst;
		if (tot + del > 100) {
			val = lst + 100 - tot;
			tar.value = val;
			obj.lastValue = val;
			opts.votingTokens = 100;
		    console.log('bump', val, tot)
		} else {
		opts.votingTokens += del;
		obj.lastValue = val;
		console.log(TemplateVar.get("matterOptions").matterName, tar.id, val, opts["votingTokens"]);			
		}
		TemplateVar.set("matterOptions",opts);
	},

	'submit form'(event, template) {
		event.preventDefault();
		targ = event.target;
		opts = TemplateVar.get("matterOptions");
		for(var i=0; i < opts["numOptions"]; i++){
			r = targ[i]; // input
			v = Number(r.value); // input value
			obj = r.id.endsWith("d") ? opts.delegates[r.id.slice(0,-1)] : opts.options[r.id]
			console.log("voted:",opts["matterName"],obj.name,v);
			currentMember.get().vote(
				opts["matterName"],
				i,
				v,
				{from:ethAccount.get().address, gas:200000},
				function(e, msg){
					console.log(msg, e, "voted:",opts["matterName"],i,v);
					// currentMatter.get().address = currentDAO.get().getMatter(opts["matterName"]));
				}
			);
		}
		for(var i=0; i < opts["numDelegates"]; i++){
			var v = Number(targ[i+'d'].value);
			console.log("delegated", v,"% to ", opts.delegates[i].name);
			currentMember.get().delegateVotesTo(
				opts["matterName"],
				opts.delegates[i].name,
				v,
	            {from:ethAccount.get().address, gas:200000},
	            function(e, msg){
					console.log(msg, e, "voted:",opts["matterName"],i,v);
					// currentMatter.set(currentDAO.get().getMatter(opts["matterName"]));
				}
			)
		}
		EthElements.Modal.show('Options');
	}
})