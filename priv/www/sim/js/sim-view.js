
var TopHeader = Class.create({
	initialize: function() {
		this.status = $('status_conn');
//		this.button = $('button_conn');
		this.disconnect();
	},
	
	successConnect: function() {
		console.log("connected");
//		this.button.innerHTML = "OFF";
//		this.button.style.backgroundColor = "LightSalmon";
//		this.button.onclick = function() {websocketclient.disconnect();};
		this.status.innerHTML = "O n l i n e";
		this.status.style.color = "DarkGreen";
		$('user').update(user);
	},
	
	disconnect: function() {
//		this.button.innerHTML = "ON";
//		this.button.style.backgroundColor = "MediumSpringGreen";
//		this.button.onclick = function() {websocketclient.connect();};
		this.status.innerHTML = "O f f l i n e";
		this.status.style.color = "LightCoral";
	}
})

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
		console.log(active_contact.status);
		if (active_contact.status == "off") {
			this.contact.style.backgroundColor = "LightSalmon";
		} else if (active_contact.status == "on") {
			this.contact.style.backgroundColor = "Aquamarine";
		}
		this.userId.update(user);
		this.contact.value = active_contact.id;
	},
	
	doUnlink: function() {
//		this.button.innerHTML = "Link to";
//		this.button.style.backgroundColor = "MediumSpringGreen";
//		this.button.onclick = function() {link();};
//		this.contact.removeAttribute("readonly");
		this.contact.style.backgroundColor = "White";
	}
})

var SendFooter = Class.create({
	initialize: function() {
		this.textArea = $('text-area');
//		this.button = $('button_send');
	},
	
	payload: function() {
		var timestamp = moment().format('MM-DD-YY HH:mm');
		var payload = {msg: this.textArea.value, time: timestamp};
		return payload;
	},
})

var Board = Class.create({
	initialize: function() {
		this.board = $('board');
	},
	
	outMessage: function(payload) {
		var div = new Element('div', {class:'left-msg'});
		var textMsg = new Element('span', {class:'text-msg'});
		var time = new Element('span', {class:'text-timestamp'});
		div.insert(textMsg);
		div.insert(time);
		this.board.insert(div);
		textMsg.update(payload.msg);
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
		console.log(who);
		var div = new Element('div', {class: 'right-msg'});
		var textMsg = new Element('span', {class:'text-msg'});
		var time = new Element('span', {class:'text-timestamp'});
		var sender = new Element('span', {class:'text-sender', onclick:'change_contact("' + who + '");'});
		div.insert(sender);
		div.insert(time);
		div.insert(textMsg);
		this.board.insert(div);
		textMsg.update(payload.msg);
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
	contacts.forEach(
		function(element, index, array)
		{ 
			var div = new Element('div', {class: 'left-msg'});
			var contName = new Element('span', {class:'text-msg'});
			var status = new Element('span', {class:'cont-state'});
			var remove = new Element('span', {class:'', onclick:'remove_contact("' + element.id + '");'});
			var connect = new Element('span', {class:''});
			connect.onclick = function(e){gotoChat(element, contacts);};
			div.insert(status);
			div.insert(contName);
			div.insert(connect);
			div.insert(remove);
			board.insert(div);
			contName.update(element.id);
			status.update(element.status);
			remove.update(' (-) ');
			connect.update(' (-c->) ');
			var isScrolledToBottom = (board.scrollHeight - board.clientHeight) <= (board.scrollTop + 1);
			if(!isScrolledToBottom) {
				board.scrollTop = board.scrollHeight - board.clientHeight;
			}
		});
}
