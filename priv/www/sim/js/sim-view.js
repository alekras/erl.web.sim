
var LinkHeader = Class.create({
	initialize: function() {
		this.contact = $('contact');
//		this.button = $('button_link');
		this.userId = $('user');
		this.doUnlink();
	},
	
	doLink: function(active_contact) {
//		this.button.innerHTML = "Unlink";
//		this.button.style.backgroundColor = "LightSalmon";
//		this.button.onclick = function() {unlink();};
//		this.contact.setAttribute("readonly", "readonly");
		console.log("doLink: contact status = " + active_contact.status);
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
		var div = new Element('div', {class: 'right-msg'});
		var textMsg = new Element('span', {class:'text-msg'});
		var time = new Element('span', {class:'text-timestamp'});
		var sender = new Element('span', {class:'text-sender', onclick:'change_contact("' + who + '");'});
		div.insert(sender);
		div.insert(time);
		div.insert(textMsg);
		this.board.insert(div);
		var txt = payload.msg.replace(/ /g, '&nbsp;').replace(/\n/g, '<br>');
		textMsg.update(txt);
//		textMsg.update(payload.msg);
		time.update(payload.time);
		sender.update(who + " :");
		var isScrolledToBottom = (this.board.scrollHeight - this.board.clientHeight) <= (this.board.scrollTop + 1);
		if(!isScrolledToBottom) {
			this.board.scrollTop = this.board.scrollHeight - this.board.clientHeight;
		}
	}
	
})

function render_contacts(contacts) {
	var board = $('contacts');
	board.childElements().forEach(function(child){child.remove()}); // clean up board
	board.contacts = contacts;
	contacts.forEach(
		function(element, index, array)
		{ 
			var div = new Element('div', {class: 'left-msg contact-list'});
			var contName = new Element('span', {class:'user-id'});
//			var status = new Element('span', {class:'cont-state'});
			var remove = new Element('span', {class:'remove-contact', onclick:'remove_contact("' + element.id + '");'});
			var connect = new Element('span', {class:'connect-contact'});
			connect.onclick = function(e){gotoChat(element, contacts);};

			if (element.status == "off") {
				contName.style.backgroundColor = "LightSalmon";
			} else if (element.status == "on") {
				contName.style.backgroundColor = "Aquamarine";
			}

//			div.insert(status);
			div.insert(contName);
			div.insert(connect);
			div.insert(remove);
			board.insert(div);
			contName.update(element.id);
//			status.update(element.status);
			remove.update(' (-) ');
			connect.update(' (-c->) ');
			var isScrolledToBottom = (board.scrollHeight - board.clientHeight) <= (board.scrollTop + 1);
			if(!isScrolledToBottom) {
				board.scrollTop = board.scrollHeight - board.clientHeight;
			}
		});
}
