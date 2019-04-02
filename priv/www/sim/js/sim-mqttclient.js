var user, user_password, 
//	contactId = "", 
	contactNames, 
	top_header, link_header, send_footer, board;

function send(contactId) {
//	var topic =  "/" + contactId + "/" + user;
	var payload = send_footer.payload()
	var stringPayload = JSON.stringify(payload);
	if (!websocketclient.connected) {
		websocketclient.connect();
		$('td-chat-error').innerHTML = "Try to send again."
		return false;
	}

	if (!websocketclient.subscribed) {
		$('td-chat-error').innerHTML = "You are not linked to other contact."
		return false;
	}

	$('td-chat-error').innerHTML = ""
	websocketclient.send(stringPayload);
	board.outMessage(payload);
}

function link(contactId, contactList) {
//	contactId = $('contact').value;
	websocketclient.contactId = contactId;
	websocketclient.contacts = contactList;
	console.log("link: contact id= '" + contactId + "'");
//	var topic = "/" + user + "/" + contactId;

	if (!websocketclient.connected) {
		websocketclient.connect();
//		console.log("link: is conn - " + websocketclient.connected);
//		$('td-chat-error').innerHTML = "Try to link again."
		return false;
	} else {
		websocketclient.onConnect();
	}

//	if (websocketclient.subscriptions.some(function (element, index, array) { return (element.topic == topic);})) {
//		$('td-chat-error').innerHTML = "You are already linked to this contact."
//		return false;
//	}

//	websocketclient.subscribe(topic);
//	$('td-chat-error').innerHTML = "";
//	link_header.doLink();
}

//function unlink(contactId) {
//	var topic = "/" + user + "/" + contactId;
//	websocketclient.unsubscribe(topic);
//	link_header.doUnlink();
////	contactId = "";
//}

var websocketclient = {
	'client': null,
	'subscriptions': [],
	'contacts': [],
	'messages': [], // ???
	'connected': false,
	'subscribed': false,
	'contactId': "",
	
	'create': function(host, port, user, password) {
//		var host = "192.168.1.75";
//		var host = "lucky3p.com";
		this.host = host; //"localhost";
		this.port = port; //8880;
		var ssl = false;
//		var host = "192.168.1.71";
//		var port = 4443;
//		var ssl = true;
//		this.clientId = user;
		this.username = user;
		this.password = password;
		
		var keepAlive = 60;
		var cleanSession = true;
		var lwTopic = "";
		var lwQos = 0;
		var lwRetain = false;
		var lwMessage = "";
	
		this.client = new Messaging.Client(host, port, user);
		this.client.onConnectionLost = this.onConnectionLost.bind(this);
		this.client.onMessageArrived = this.onMessageArrived.bind(this);
	
		this.options = {
			timeout: 10,
			keepAliveInterval: keepAlive,
			cleanSession: cleanSession,
			useSSL: ssl,
			onSuccess: this.onConnect.bind(this),
			onFailure: this.onFail.bind(this)
		};
		if (user.length > 0) {
			this.options.userName = user;
		}
		if (password.length > 0) {
			this.options.password = password;
		}
		if (lwTopic.length > 0) {
			var willmsg = new Messaging.Message(lwMessage);
			willmsg.qos = lwQos;
			willmsg.destinationName = lwTopic;
			willmsg.retained = lwRetain;
			options.willMessage = willmsg;
		}
	},

	'connect': function () {
		if (this.connected) {
			return;
		}
	
		this.client.connect(this.options);
	},

	'onConnect': function () {
		this.connected = true;
		top_header.successConnect();
console.log("on Connect: " + this.contactId);
		if (this.contactId.length > 0) {
			var topic = "/" + this.username + "/" + this.contactId;
			this.subscribe(topic);
			link_header.doLink(this.contactId);
		}
	},

	'send': function (payload) {
		var topic =  "/" + this.contactId + "/" + this.username;
		var message = new Messaging.Message(payload);
		message.destinationName = topic;
		message.qos = 2;
		message.retained = true;
		this.client.send(message);
	},

	'onFail': function (message) {
		this.connected = false;
		this.subscribed = false;
		$('td-chat-error').innerHTML = "Connection is broken.";
		console.log("error: " + message.errorMessage);
		top_header.disconnect();
	},

	'onConnectionLost': function (responseObject) {
		this.connected = false;
		if (responseObject.errorCode !== 0) {
			$('td-chat-error').innerHTML = "Cannot establish connection.";
			console.log("onConnectionLost:" + responseObject.errorMessage);
		}
		top_header.disconnect();

	//Cleanup subscriptions
		this.subscribed = false;
		link_header.doUnlink();
		this.subscriptions = [];
	},

	'subscribe': function (topic) {
		if (this.subscriptions.some(function (element, index, array) { return (element.topic == topic);})) {
			console.log("You are already linked to this contact.");
			return;
		}
		this.client.subscribe(topic, {qos: 2});
		this.subscriptions.push({'topic': topic, 'qos': 2});
		this.subscribed = true;
	},

	'unsubscribe': function (topic) {
		this.client.unsubscribe(topic);
		this.subscriptions = this.subscriptions.filter(function (element, index, array) { return element.topic != topic;});
		this.subscribed = false;
	},

	'onMessageArrived': function (message) {
		console.log("Message arrives: " + message.payloadString + " topic: " + message.destinationName 
				+ " qos: " + message.qos + " retained: " + message.retained);
		board.inMessage(message);

// Acknowledge endpoint to delete retain message as already delivered. 
//		if (message.retained) {
			var messageAck = new Messaging.Message('');
			var topic = "/" + this.username + "/" + this.contactId;
			messageAck.destinationName = topic;
			messageAck.qos = 2;
			messageAck.retained = true;
			this.client.send(messageAck);
//		}
	},
// do I need it? --Yes!
	'disconnect': function () {
		if (!this.connected) {
			return;
		}
		var topic = "/" + this.username + "/" + this.contactId;
		this.unsubscribe(topic);
		link_header.doUnlink();
		this.connected = false;
		this.contactId = "";
		console.log("disconnect: " + this.username);
		this.client.disconnect();
		top_header.disconnect();
	}

}
