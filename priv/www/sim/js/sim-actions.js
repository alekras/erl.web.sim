function gotoLogin() {
	user = "";
	user_password = "";
	websocketclient.disconnect();
	$('login-tbl').style.display = 'table';
	$('reg-tbl').style.display = 'none';
	$('chat-tbl').style.display = 'none';
	$('contacts-tbl').style.display = 'none';
	$('help-tbl').style.display = 'none';
	$('td-login-error').innerHTML = "";
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

function gotoChat(contactId) {
	console.log("gotoChat: contact id= " + contactId);
//	$('login-tbl').style.display = 'none';
	$('chat-tbl').style.display = 'table';
	$('contacts-tbl').style.display = 'none';
	$('help-tbl').style.display = 'none';
	$('td-chat-error').innerHTML = "Chat";
	link(contactId);
}

function gotoHelp() {
//	$('login-tbl').style.display = 'none';
//	$('reg-tbl').style.display = 'none';
	$('chat-tbl').style.display = 'none';
	$('contacts-tbl').style.display = 'none';
	$('help-tbl').style.display = 'table';
	$('td-help-error').innerHTML = "Help";
}

function parse_contacts(contacts) {
	return contacts.map(function(element, index, array) { return element.id;});
}