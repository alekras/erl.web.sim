var user, user_password, contactId = "", 
	contactNames, 
	top_header, link_header, send_footer, board;

function send() {
	var topic =  "/" + contactId + "/" + user;
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
	var message = new Messaging.Message(stringPayload);
	message.destinationName = topic;
	message.qos = 2;
	message.retained = true;
	websocketclient.client.send(message);
	board.outMessage(payload);
}

function link() {
	contactId = $('contact').value;
	var topic = "/" + user + "/" + contactId;

	if (!websocketclient.connected) {
		websocketclient.connect();
		$('td-chat-error').innerHTML = "Try to link again."
		return false;
	}

	if (contactId.length < 1) {
		$('td-chat-error').innerHTML = "Contact name cannot be empty."
		return false;
	}

	if (websocketclient.subscriptions.some(function (element, index, array) { return (element.topic == topic);})) {
		$('td-chat-error').innerHTML = "You are already linked to this contact."
		return false;
	}

	websocketclient.client.subscribe(topic, {qos: 2});

	websocketclient.subscriptions.push({'topic': topic, 'qos': 2});
	websocketclient.subscribed = true;

	$('td-chat-error').innerHTML = "";
	link_header.doLink();
}

function unlink() {
	var topic = "/" + user + "/" + contactId;
	websocketclient.unsubscribe(topic);
	link_header.doUnlink();
	contactId = "";
}

var websocketclient = {
	'client': null,
	'subscriptions': [],
	'messages': [],
	'connected': false,
	'subscribed': false,
	

	'connect': function () {

//		var host = "192.168.1.75";
//		var host = "lucky3p.com";
		var host = "localhost";
		var port = 8880;
		var ssl = false;
//		var host = "192.168.1.71";
//		var port = 4443;
//		var ssl = true;
		var clientId = user;
		var username = user;
		var password = user_password;
		var keepAlive = 60;
		var cleanSession = true;
		var lwTopic = "";
		var lwQos = 0;
		var lwRetain = false;
		var lwMessage = "";
	
		this.client = new Messaging.Client(host, port, clientId);
		this.client.onConnectionLost = this.onConnectionLost;
		this.client.onMessageArrived = this.onMessageArrived;
	
		var options = {
			timeout: 10,
			keepAliveInterval: keepAlive,
			cleanSession: cleanSession,
			useSSL: ssl,
			onSuccess: this.onConnect,
			onFailure: this.onFail
		};
	
		if (username.length > 0) {
			options.userName = username;
		}
		if (password.length > 0) {
			options.password = password;
		}
		if (lwTopic.length > 0) {
			var willmsg = new Messaging.Message(lwMessage);
			willmsg.qos = lwQos;
			willmsg.destinationName = lwTopic;
			willmsg.retained = lwRetain;
			options.willMessage = willmsg;
		}
	
		this.client.connect(options);
	},

	'onConnect': function () {
		websocketclient.connected = true;
		top_header.successConnect();
	console.log("on Connect: " + contactId);
		if (contactId.length > 0) {
			var topic = "/" + user + "/" + contactId;
			websocketclient.client.subscribe(topic, {qos: 2});
			websocketclient.subscriptions.push({'topic': topic, 'qos': 2});
			websocketclient.subscribed = true;
			link_header.doLink();
		}
	},

	'onFail': function (message) {
		websocketclient.connected = false;
		websocketclient.subscribed = false;
		$('td-chat-error').innerHTML = "Connection is broken.";
		console.log("error: " + message.errorMessage);
		top_header.disconnect();
	},

	'onConnectionLost': function (responseObject) {
		websocketclient.connected = false;
		if (responseObject.errorCode !== 0) {
			$('td-chat-error').innerHTML = "Cannot establish connection.";
			console.log("onConnectionLost:" + responseObject.errorMessage);
		}
		top_header.disconnect();

	//Cleanup subscriptions
		websocketclient.subscribed = false;
		link_header.doUnlink();
		websocketclient.subscriptions = [];
	},

	'unsubscribe': function (topic) {
		this.client.unsubscribe(topic);
		websocketclient.subscriptions = websocketclient.subscriptions.filter(function (element, index, array) { return element.topic != topic;});
		this.subscribed = false;
	},

	'onMessageArrived': function (message) {
		console.log("Message arrives: " + message.payloadString + " topic: " + message.destinationName 
				+ " qos: " + message.qos + " retained: " + message.retained);
		board.inMessage(message);

// Acknowledge endpoint to delete retain message as already delivered. 
//		if (message.retained) {
			var messageAck = new Messaging.Message('');
			var topic = "/" + user + "/" + contactId;
			messageAck.destinationName = topic;
			messageAck.qos = 2;
			messageAck.retained = true;
			websocketclient.client.send(messageAck);
//		}
	},
// do I need it?
	'disconnect': function () {
		var topic = "/" + user + "/" + contactId;
		websocketclient.unsubscribe(topic);
		link_header.doUnlink();
		this.connected = false;
		this.client.disconnect();
		top_header.disconnect();
	}

}
