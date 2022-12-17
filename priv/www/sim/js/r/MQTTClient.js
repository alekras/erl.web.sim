'use strict';

class MQTTClient {

	constructor(config) {
		this.client = new Messaging.Client(config.host, config.port, config.user);
		this.client.onConnectionLost = this.onConnectionLost;
		this.client.onMessageArrived = this.onMessageArrived;
		
		this.options = {};
		this.options.timeout = 10;
		this.options.keepAliveInterval = 60;
		this.options.cleanSession = true;
		this.options.useSSL = config.ssl;
		this.options.onSuccess = this.onConnect;
		this.options.onFailure = this.onFailure;
		this.options.userName = config.user;
		this.options.password = config.password;
		
		this.options.willMessage = new Messaging.Message(''); // will message payload
		this.options.willMessage.qos = 0;
		this.options.willMessage.destinationName = '';
		this.options.willMessage.retained = false;
		
		this.afterMsgArrive = config.afterArrive,
		
		this.connected = false;
		this.contact = '';
		this.topics = new Map();
	}

/** Callback functions */	

	onConnect = () => {
		this.connected = true;
		console.log("on Connect. contact: " + this.contact 
			+ "; is connected: " + this.connected 
		);
		this.onReady(true);
	}

	onReady = (msg) => {
		if (msg) {
			var contactObj = BoardContacts.contacts[this.options.userName]
			if (contactObj) {
				contactObj.status = 'on';
			}
			console.log(">>> onReady, Contact list: " + JSON.stringify(BoardContacts.contacts));
			if (this.connected) {
				this.subscribeAll(BoardContacts.contacts);
			}
		}
	}
	
	onFailure = (errorMsg) => {
		this.connected = false;
//		new WarningBox("Connection is broken.");
		console.log("MQTT client onFailure error: " + errorMsg.errorMessage);
	//Cleanup subscriptions
		this.topics.clear();
	}
	
	onConnectionLost = (responseMsg) => {
		this.connected = false;
		console.log("MQTT client onConnectionLost error:" + responseMsg.errorMessage + ' code:' + responseMsg.errorCode);

	//Cleanup subscriptions
		this.topics.clear();
	}
	
	onMessageArrived = (msg) => {
		console.log("Message arrives: " + msg.payloadString 
			+ " topic: " + msg.destinationName 
			+ " qos: " + msg.qos 
			+ " retained: " + msg.retained
			+ " duplicate: " + msg.duplicate);
		var who = msg.destinationName.split("/")[2];

		BoardChat.onMessageArrived(msg.payloadString, who);
// Acknowledge endpoint to delete retain message as already delivered. 
		if (msg.retained) {
			var messageAck = new Messaging.Message('');
			var topic = "/" + this.options.userName + "/" + who;
			messageAck.destinationName = topic;
			messageAck.qos = 2;
			messageAck.retained = true;  // ? false ?
			this.client.send(messageAck);
			console.log("Empty message sent: " + messageAck.payloadString 
				+ " topic: " + messageAck.destinationName 
				+ " qos: " + messageAck.qos 
				+ " retained: " + messageAck.retained);
		}
		this.afterMsgArrive();
	}

/** client API functions */	

	connect = () => {
		if (!this.connected) {
			this.client.connect(this.options);
		} else {
//			this.onReady({status:'connected'});
		}
	}
	
	disconnect = () => {
		if (this.connected) {
			this.connected = false;
			this.contact = '';
	//Cleanup subscriptions
			this.topics.clear();
			console.log("disconnect: " + this.username);
			this.client.disconnect();
		}
	}
	
	subscribe = (contact) => {
		var topic = "/" + this.options.userName + "/" + contact;
		this.topics.set(contact, topic);
		this.client.subscribe(topic, {qos: 2});
		console.log("Subscribed topic: " + topic);
	}
	
	unsubscribe = (contact) => {
		var topic = this.topics.get(contact);
		this.topics.delete(contact);
		this.client.unsubscribe(topic);
		console.log("UnSubscribed topic: " + topic);
	}
	
	subscribeAll = (contactList) => {
//		console.log(">>> subscribeAll " + JSON.stringify(contactList));
		Object.entries(contactList).forEach(([contactName, value]) => {
//			console.log(">>> inside forEach  "+this.topics.get(contactName));
			if (!this.topics.get(contactName)) {
				this.subscribe(contactName);
			}
		});
	}
	
	unsubscribeAll = (contactList) => {
		Object.entries(contactList).forEach(([contactName, value]) => {
			this.unsubscribe(contactName);
		});
	}
	
	send = (payloadObj) => {
		var contactStatus;
		if (this.contact == this.options.userName) {
			contactStatus = 'on';
		} else {
			contactStatus = BoardContacts.contacts[this.contact].status;
		}
		
//		console.log('contacts:: ' + JSON.stringify(BoardContacts.contacts));
//		console.log("Before Message sent: contact = " 
//			+ this.contact
//			+ " status = " + contactStatus); 
		var stringPayload = JSON.stringify(payloadObj);
		var message = new Messaging.Message(stringPayload);
		message.destinationName = '/' + this.contact + '/' + this.options.userName;
		message.qos = 2;
		if (contactStatus == "on") {
			message.retained = false;
		} else {
			message.retained = true;
		}
		this.client.send(message);
		console.log("Message sent: " + stringPayload 
			+ " topic: " + message.destinationName 
			+ " qos: " + message.qos 
			+ " retained: " + message.retained 
			+ " to contact: " + this.contact);
	}
}