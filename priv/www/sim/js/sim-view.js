
var LinkHeader = Class.create({
	initialize: function() {
		this.contact = $('contact');
		this.userId = $('user');
		this.doUnlink();
	},
	
	doLink: function(active_contact) {
//		this.button.innerHTML = "Unlink";
//		this.button.style.backgroundColor = "LightSalmon";
//		this.button.onclick = function() {unlink();};
//		this.contact.setAttribute("readonly", "readonly");
//		console.log("doLink: contact status = " + active_contact.status);
		if (active_contact.status == "off") {
			this.contact.style.backgroundColor = "LightSalmon";
		} else if (active_contact.status == "on") {
			this.contact.style.backgroundColor = "Aquamarine";
		}
		this.userId.update(user);
		this.userId.style.backgroundColor = "Aquamarine";
		this.contact.update(active_contact.id);
//		this.contact.value = active_contact.id;
	},
	
	doUnlink: function() {
//		this.button.innerHTML = "Link to";
//		this.button.style.backgroundColor = "MediumSpringGreen";
//		this.button.onclick = function() {link();};
//		this.contact.removeAttribute("readonly");
//		this.contact.update("c");
		this.contact.style.backgroundColor = "White";
		this.userId.style.backgroundColor = "LightSalmon";
	}
})

var SendFooter = Class.create({
	initialize: function() {
		this.textArea = $('text-area');
//		this.button = $('button_send');
	},
	
	payload: function() {
		console.log("text area = " + this.textArea.value);
		var timestamp = moment().format('MM-DD-YY HH:mm');
		var payload = {msg: this.textArea.value, time: timestamp};
		return payload;
	},
})

var Board = Class.create({
	initialize: function() {
		this.board = $('board');
	},
	
	clear: function() {
		this.board.childElements().forEach(function(child){child.remove()}); // clean up board
	},
	
	outMessage: function(payload) {
		var div = new Element('div', {class:'left-msg'});
		var textMsg = new Element('span', {class:'text-msg'});
		var time = new Element('span', {class:'text-timestamp'});
		div.insert(textMsg);
		div.insert(time);
		this.board.insert(div);
		var txt = payload.msg.replace(/ /g, '&nbsp;').replace(/\n/g, '<br>');
		textMsg.update(txt);
//		textMsg.update(payload.msg);
		time.update(payload.time);
		var isScrolledToBottom = (this.board.scrollHeight - this.board.clientHeight) <= (this.board.scrollTop + 1);
		if(!isScrolledToBottom) {
			this.board.scrollTop = this.board.scrollHeight - this.board.clientHeight;
		};
		$('text-area').value = ""
	},
	
	inMessage: function(message) {
		var payload = JSON.parse(message.payloadString);
		var who = message.destinationName.split("/")[2];
//		console.log(who);
		var rowDiv = new Element('div', {class: '', style:'display:block;'});
		var div = new Element('div', {class: 'right-msg'});
		var textMsg = new Element('span', {class:'text-msg'});
		var time = new Element('span', {class:'text-timestamp'});
		var sender = new Element('span', {class:'text-sender', onclick:'change_contact("' + who + '");'});
		div.insert(textMsg);
		div.insert(time);
		rowDiv.insert(div);
		sender.update(who + " :");
		rowDiv.insert(sender);
		this.board.insert(rowDiv);
		var txt = payload.msg.replace(/ /g, '&nbsp;').replace(/\n/g, '<br>');
		textMsg.update(txt);
//		textMsg.update(payload.msg);
		time.update(payload.time);
		var isScrolledToBottom = (this.board.scrollHeight - this.board.clientHeight) <= (this.board.scrollTop + 1);
		if(!isScrolledToBottom) {
			this.board.scrollTop = this.board.scrollHeight - this.board.clientHeight;
		}
	}	
})

var Contacts = Class.create({
	initialize: function() {
		this.board = $('contacts');
		this.contacts = [];
	},

	clear: function() {
		this.board.childElements().forEach(function(child){child.remove()}); // clean up board
	},
	
	render_contacts: function(contacts) {
		this.board.childElements().forEach(function(child){child.remove()}); // clean up board
		this.contacts = contacts;
		contacts.forEach(
			function(element, index, array) { 
				var div = new Element('div', {class: 'left-msg contact-list'});
				var contName = new Element('span', {class:'user-id'});
				var remove = new Element('span', {class:'remove-contact', onclick:'confirm_contact_remove("' + element.id + '");'});
				var connect = new Element('span', {class:'connect-contact'});
//				var connect = new Element('img', {src:'/sim/img/connect.png', class:'connect-contact'});
				connect.onclick = function(e){gotoChat(element, contacts);};

				if (element.status == "off") {
					contName.style.backgroundColor = "LightSalmon";
				} else if (element.status == "on") {
					contName.style.backgroundColor = "Aquamarine";
				} else if (element.status == "undefined") {
					contName.style.backgroundColor = "white";
				}

				div.insert(contName);
				div.insert(connect);
				div.insert(remove);
				this.board.insert(div);
				contName.update(element.id);
		}.bind(this));
		var isScrolledToBottom = (this.board.scrollHeight - this.board.clientHeight) <= (this.board.scrollTop + 1);
		if(!isScrolledToBottom) {
			this.board.scrollTop = this.board.scrollHeight - this.board.clientHeight;
		}
	}
})

var ConfirmBox = Class.create({
	initialize: function(contct_id) {
		this.contact_id = contct_id;
		this.mask = this.create();
	},
	
	create: function() {
		var parent = $('contacts-tbl');
		var par_layout = parent.getLayout();
		var x = par_layout.get('left');
		var y = par_layout.get('top');
		var w = par_layout.get('width');
		var h = par_layout.get('height');
		
//		console.log("x= " + par_layout.get('left') 
//				+ " y= " + par_layout.get('top') 
//				+ "\n w= " + par_layout.get('width') 
//				+ " h= " + par_layout.get('height') );
		var mask = new Element('div', {class:'confirm-mask'});
		mask.setStyle({width: w + 'px', height: h + 'px', top: y + 'px', left: x + 'px'});
		var tbox = new Element('div', {class:'confirm-box'});
		
		var inside = new Element('div', {class:'confirm-inside'});
		var message = new Element('div', {class:'confirm-msg'});
		var yes = new Element('span', {class:'confirm-btn'});
		yes.onclick = function(e){confirm_yes(this.contact_id); this.destroy()}.bind(this);
		var no = new Element('span', {class:'confirm-btn'});
		no.onclick = function(e){confirm_no(); this.destroy()}.bind(this);
		inside.insert(message);
		inside.insert(yes);
		inside.insert(no);
		yes.update('Yes');
		no.update('No');
		message.update("Do you want to remove '<b>" + this.contact_id + "</b>' from your contacts list?");

		tbox.insert(inside);
		mask.insert(tbox);
		parent.insert(mask);
		var layout = tbox.getLayout();
		var w1 = layout.get('width');
		var h1 = layout.get('height');
		var x1 = (w - w1) / 2;
		var y1 = (h - h1) / 2;

//		console.log("x= " + x1 
//				+ " y= " + y1 
//				+ "\n w= " + w1 
//				+ " h= " + h1 );
		tbox.setStyle({top: y1 + 'px', left: x1 + 'px'});
		return mask;
	},
	
	destroy: function() {
		this.mask.remove();
	}

})

var WarningBox = Class.create({
	initialize: function(warn_txt) {
		this.warning = warn_txt;
		this.mask = this.create();
	},
	
	create: function() {
		var parent = $('container');
		var par_layout = parent.getLayout();
		var x = par_layout.get('left');
		var y = par_layout.get('top');
		var w = par_layout.get('width');
		var h = par_layout.get('height');
		
		console.log("x= " + par_layout.get('left') 
				+ " y= " + par_layout.get('top') 
				+ "\n w= " + par_layout.get('width') 
				+ " h= " + par_layout.get('height') );
		var mask = new Element('div', {class:'confirm-mask'});
		mask.setStyle({width: w + 'px', height: h + 'px', top: y + 'px', left: x + 'px'});
		var tbox = new Element('div', {class:'confirm-box'});
		
		var inside = new Element('div', {class:'confirm-inside'});
		var message = new Element('div', {class:'confirm-msg'});
		var close = new Element('span', {class:'confirm-btn'});
		close.onclick = function(e){this.destroy()}.bind(this);
		inside.insert(message);
		inside.insert(close);
		close.update('Close');
		message.update(this.warning);

		tbox.insert(inside);
		mask.insert(tbox);
		parent.insert(mask);
		var layout = tbox.getLayout();
		var w1 = layout.get('width');
		var h1 = layout.get('height');
		var x1 = (w - w1) / 2;
		var y1 = (h - h1) / 2;

//		console.log("x= " + x1 
//				+ " y= " + y1 
//				+ "\n w= " + w1 
//				+ " h= " + h1 );
		tbox.setStyle({top: y1 + 'px', left: x1 + 'px'});
		return mask;
	},
	
	destroy: function() {
		this.mask.remove();
	}

})
