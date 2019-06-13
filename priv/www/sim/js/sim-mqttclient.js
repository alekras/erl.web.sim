var user, user_password, 
	contactNames, 
	link_header, send_footer, board, contacts_board;

function send() {
//	var topic =  "/" + contactId + "/" + user;
	if (!websocketclient.connected) {
		websocketclient.connect();
		$('td-error').innerHTML = "Try to send again."
		return false;
	}

//	if (!websocketclient.subscribed) {
//		$('td-error').innerHTML = "You are not linked to other contact."
//		return false;
//	}

//	$('td-error').innerHTML = ""
	var payload = send_footer.payload()
	var stringPayload = JSON.stringify(payload);
	websocketclient.send(stringPayload);
	board.outMessage(payload);
}

function link(contact, contactList) {
	websocketclient.contact = contact;
	websocketclient.contacts = contactList;
	console.log("link: contact id= '" + contact.id + "'\n" + JSON.stringify(contactList));

	if (!websocketclient.connected) {
		websocketclient.connect();
		return false;
	} else {
		websocketclient.onConnect();
		return true;
	}
}

function first_time_link(contact) {
	websocketclient.contact = contact;
	console.log("first time link: contact id= '" + contact.id + "'");

	if (!websocketclient.connected) {
		websocketclient.contacts = [];
		websocketclient.connect();
	} else {
//		websocketclient.onConnect();
	}
}

function reLink(contact) {
	websocketclient.contact = contact;
	console.log("reLink: contact id= '" + contact.id + "'");

	if (!websocketclient.connected) {
		websocketclient.connect();
		return false;
	} else {
		websocketclient.onConnect();
	}

}

var websocketclient = {
	'client': null,
//	'subscriptions': [],
	'contacts': [],
	'messages': [], // ???
	'connected': false,
	'subscribed': false,
	'contact': {},
	
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
//		top_header.successConnect();
console.log("on Connect: " + this.contact.id + "\n" + JSON.stringify(this.contacts));
		this.subscribe(); 
		link_header.doLink(this.contact);
	},

	'onFail': function (message) {
		this.connected = false;
		this.subscribed = false;
		$('td-error').innerHTML = "Connection is broken.";
		console.log("error: " + message.errorMessage);
//		top_header.disconnect();
	},

	'onConnectionLost': function (responseObject) {
		this.connected = false;
		if (responseObject.errorCode !== 0) {
			$('td-error').innerHTML = "Cannot establish connection.";
			console.log("onConnectionLost:" + responseObject.errorMessage);
		}
//		top_header.disconnect();

	//Cleanup subscriptions
		this.subscribed = false;
		link_header.doUnlink();
		make_logout();
//		this.subscriptions = [];
	},

	'subscribe': function () {
//		if (this.subscriptions.some(function (element, index, array) { return (element.topic == topic);})) {
//			console.log("You are already linked to this contact.");
//			return;
//		}
		var mapFun = function(element, index, array) { 
			var topic = "/" + this.username + "/" + element.id;
			this.client.subscribe(topic, {qos: 2});
			console.log("Subscribed topic: " + topic);
		}.bind(this);
		this.contacts.map(mapFun);
//		this.subscriptions.push({'topic': topic, 'qos': 2});
		this.subscribed = true;
	},

	'unsubscribe': function (topic) {
		this.client.unsubscribe(topic);
//		this.subscriptions = this.subscriptions.filter(function (element, index, array) { return element.topic != topic;});
//		this.subscribed = false;
	},

	'send': function (payload) {
		var topic =  "/" + this.contact.id + "/" + this.username;
		var message = new Messaging.Message(payload);
		message.destinationName = topic;
		message.qos = 2;
		message.retained = true;
		this.client.send(message);
	},

	'onMessageArrived': function (message) {
		console.log("Message arrives: " + message.payloadString + " topic: " + message.destinationName 
				+ " qos: " + message.qos + " retained: " + message.retained);
		board.inMessage(message);
// Acknowledge endpoint to delete retain message as already delivered. 
		if (message.retained) {
			var who = message.destinationName.split("/")[2];
			var messageAck = new Messaging.Message('');
//			var topic = "/" + this.username + "/" + this.contact.id;
			var topic = "/" + this.username + "/" + who;
			messageAck.destinationName = topic;
			messageAck.qos = 2;
			messageAck.retained = true;
			this.client.send(messageAck);
			console.log("Empty message sent: " + messageAck.payloadString + " topic: " + messageAck.destinationName 
					+ " qos: " + messageAck.qos + " retained: " + message.retained);
		}
	},
// do I need it? --Yes!
	'disconnect': function () {
		if (this.connected) {
//			var topic = "/" + this.username + "/" + this.contactId;
//			this.unsubscribe(topic);
			this.connected = false;
			this.contact = {id:"",status:""};
			console.log("disconnect: " + this.username);
			this.client.disconnect();
		}
		link_header.doUnlink();
		make_logout();
//		top_header.disconnect();
	}

}
