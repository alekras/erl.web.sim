function doLoginRequest() {
	new Ajax.Request('/sim/login',{
		method: 'post',
		parameters: {user: $('f1').value, password: $('f2').value},
		requestHeaders: {Accept: 'application/json'},
		onSuccess: function(transport){
			console.log(transport.responseJSON.status);
			if (transport.responseJSON.status == 'ok') {
				user = $('f1').value;
				user_password = $('f2').value;
				$('login-tbl').style.display = 'none';
				$('chat-tbl').style.display = 'table';
				$('td-chat-error').innerHTML = "";
				websocketclient.connect();
			} else {
				$('td-login-error').innerHTML = "User name or Password are invalid.<br/>Please try again.";
			}
		}
	});
}

function doRegisterRequest() {
	$('register').	setAttribute("disabled", "disabled");
	new Ajax.Request('/sim/register',{
		method: 'post',
		parameters: {user: $('f3').value, password1: $('f4').value, password2: $('f5').value},
		requestHeaders: {Accept: 'application/json'},
		postBody: "",
		onSuccess: function(transport){
			console.log(transport.responseJSON.status + " | " + transport.responseJSON.reason);
			if (transport.responseJSON.status == 'ok') {
				$('reg-tbl').style.display = 'none';
				$('login-tbl').style.display = 'table';
				$('td-login-error').innerHTML = "You are successfully registered";
				$('td-reg-error').innerHTML = "You are successfully registered";
			} else {
				if (transport.responseJSON.reason == 'exist') {
					$('td-reg-error').innerHTML = "This user name already exists.<br/>Please try another.";
				} else if (transport.responseJSON.reason == 'password') {
					$('td-reg-error').innerHTML = "Password is too short or does not fit confirmed.<br/>Please try again.";
				}
			}
		},
		
		onComplete: function(response) {
			$('register').	removeAttribute("disabled");
		}
	});
}

function gotoReq() {
	$('login-tbl').style.display = 'none';
	$('reg-tbl').style.display = 'table';
	$('td-reg-error').innerHTML = "";
}

function gotoContacts() {
	get_contacts();
//	$('login-tbl').style.display = 'none';
//	$('reg-tbl').style.display = 'none';
	$('chat-tbl').style.display = 'none';
	$('contacts-tbl').style.display = 'table';
	$('help-tbl').style.display = 'none';
	$('td-cont-error').innerHTML = "Contacts";
}

function gotoChat() {
//	$('login-tbl').style.display = 'none';
	$('chat-tbl').style.display = 'table';
	$('contacts-tbl').style.display = 'none';
	$('help-tbl').style.display = 'none';
	$('td-chat-error').innerHTML = "Chat";
}

function gotoHelp() {
//	$('login-tbl').style.display = 'none';
//	$('reg-tbl').style.display = 'none';
	$('chat-tbl').style.display = 'none';
	$('contacts-tbl').style.display = 'none';
	$('help-tbl').style.display = 'table';
	$('td-help-error').innerHTML = "Help";
}

function add_contact() {
	var new_contact = $('contact_add').value;
	new Ajax.Request("/sim/contacts/" + user + "/add/" + new_contact, {
		method: 'post',
		parameters: {},
		requestHeaders: {Accept: 'application/json'},
		postBody: "",
		onSuccess: function(transport){
//			console.log("add contact: " + transport.responseJSON.status + " | " + transport.responseJSON.reason);
//			console.log(transport.responseText);
			if (transport.responseJSON.status == 'ok') {
				contactNames = parse_contacts(transport.responseJSON.contacts);
//				contactNames.forEach(function(element, index, array) { console.log(index + ': ' + element);});
				render_contacts(transport.responseJSON.contacts);
				$('td-cont-error').innerHTML = "You are successfully add new contact";
			} else {
				if (transport.responseJSON.reason == 'not_exist') {
					$('td-cont-error').innerHTML = "This contact name does not exist.<br/>Please try another.";
				}
			}
		},
		
		onComplete: function(response) {
		}
	});
	
}

function get_contacts() {
	new Ajax.Request("/sim/contacts/" + user + "/get_all", {
		method: 'get',
		parameters: {},
		requestHeaders: {Accept: 'application/json'},
		postBody: "",
		onSuccess: function(transport){
//			console.log(transport.responseText);
//			console.log(transport.responseJSON.status + " | " + transport.responseJSON.contacts);
			if (transport.responseJSON.status == 'ok') {
				contactNames = parse_contacts(transport.responseJSON.contacts);
//				contactNames.forEach(function(element, index, array) { console.log(index + ': ' + element);});
				render_contacts(transport.responseJSON.contacts);
				$('td-cont-error').innerHTML = "You are successfully get all your contacts";
			} else {
				if (transport.responseJSON.reason == 'exist') {
					$('td-cont-error').innerHTML = "Something wrong.";
				}
			}
		},
		
		onComplete: function(response) {
		}
	});
}

function remove_contact(contactName) {
	new Ajax.Request("/sim/contacts/" + user + "/remove/" + contactName, {
		method: 'post',
		parameters: {},
		requestHeaders: {Accept: 'application/json'},
		postBody: "",
		onSuccess: function(transport){
//			console.log("remove contact: " + transport.responseJSON.status + " | " + transport.responseJSON.reason);
//		console.log(transport.responseText);
			if (transport.responseJSON.status == 'ok') {
				contactNames = parse_contacts(transport.responseJSON.contacts);
//				contactNames.forEach(function(element, index, array) { console.log(index + ': ' + element);});
				render_contacts(transport.responseJSON.contacts);
				$('td-cont-error').innerHTML = "You are successfully add new contact";
			} else {
				if (transport.responseJSON.reason == 'exist') {
					$('td-cont-error').innerHTML = "This contact name does not exist.<br/>Please try another.";
				}
			}
		},
		
		onComplete: function(response) {
		}
	});
}

function parse_contacts(contacts) {
	return contacts.map(function(element, index, array) { return element.id;});
}