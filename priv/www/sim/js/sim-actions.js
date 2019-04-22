
function init() {
	console.log(">>> init()");
	top_header = new TopHeader();
	link_header = new LinkHeader();
	send_footer = new SendFooter();
	board = new Board();
	websocketclient.create("localhost", 8880, user, user_password);
}

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

function gotoAfterSuccessLogin(p_user, p_user_password) {
	user = p_user;
	user_password = p_user_password;
	websocketclient.create("localhost", 8880, user, user_password);
	gotoContacts();
}

function gotoReq() {
	$('login-tbl').style.display = 'none';
	$('reg-tbl').style.display = 'table';
	$('td-reg-error').innerHTML = "";
}

function gotoContacts() {
	get_contacts();
	$('login-tbl').style.display = 'none';
	$('reg-tbl').style.display = 'none';
	$('chat-tbl').style.display = 'none';
	$('contacts-tbl').style.display = 'table';
	$('help-tbl').style.display = 'none';
	$('td-cont-error').innerHTML = "Contacts";
}

function gotoChatbyClick(contact) {
	console.log("gotoChatbyClick: contact id= " + contact);
	$('login-tbl').style.display = 'none';
	$('reg-tbl').style.display = 'none';
	$('chat-tbl').style.display = 'table';
	$('contacts-tbl').style.display = 'none';
	$('help-tbl').style.display = 'none';
	$('td-chat-error').innerHTML = "Chat";
	var contacts = $('contacts').contacts;
	contacts.push({id:contact,status:"on"});
	link({id:contact,status:"on"}, contacts);
}

function gotoChat(contact, ContactList) {
	console.log("gotoChat: contact id= " + contact.id);
	$('login-tbl').style.display = 'none';
	$('reg-tbl').style.display = 'none';
	$('chat-tbl').style.display = 'table';
	$('contacts-tbl').style.display = 'none';
	$('help-tbl').style.display = 'none';
	$('td-chat-error').innerHTML = "Chat";
	link(contact, ContactList);
}

function change_contact(sender) {
	console.log("change_contact: sender= " + sender);
	var search = websocketclient.contacts.filter(function(contact){console.log("filter: " + contact); return contact.id === sender});
	console.log("change_contact: search= " + search);
	if (search.length == 0) {
		console.log("change_contact: contact " + sender + " is not in your contact list.");
	} else {
		reLink(search[0]);
	}
}

function gotoHelp() {
	$('login-tbl').style.display = 'none';
	$('reg-tbl').style.display = 'none';
	$('chat-tbl').style.display = 'none';
	$('contacts-tbl').style.display = 'none';
	$('help-tbl').style.display = 'table';
	$('td-help-error').innerHTML = "Help";
}

function parse_contacts(contacts) {
	return contacts.map(function(element, index, array) { return element.id;});
}