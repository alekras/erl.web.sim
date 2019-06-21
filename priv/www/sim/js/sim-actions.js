var mqtt_host = "lucky3p.com", mqtt_port = 8880;

function init() {
	console.log(">>> init()");
//	top_header = new TopHeader();
	link_header = new LinkHeader();
	send_footer = new SendFooter();
	board = new Board();
	contacts_board = new Contacts();
//	user = "tom"; user_password = "tom";  // only for testing !!!
//	websocketclient.create("192.168.1.71", 8880, user, user_password); // only for testing !!!
//	gotoChatTest(); // only for testing !!!
	gotoLogin();
}

function gotoLogin() {
	user = "";
	user_password = "";
	websocketclient.disconnect();
	$('login_menu').style.display = 'table-row';
	$('register_menu').style.display = 'none';
	$('chat_menu').style.display = 'none';
	$('contacts_menu').style.display = 'none';
	$('help_menu_0').style.display = 'none';
	$('help_menu_1').style.display = 'none';
	
	$('login-tbl').style.display = 'table';
	$('reg-tbl').style.display = 'none';
	$('chat-tbl').style.display = 'none';
	$('contacts-tbl').style.display = 'none';
	$('help-tbl').style.display = 'none';
//	$('td-error').innerHTML = "";
}

function gotoAfterSuccessLogin(p_user, p_user_password) {
	user = p_user;
	user_password = p_user_password;
	websocketclient.create(mqtt_host, mqtt_port, user, user_password);
	gotoContacts();
}

function gotoRegister() {
	$('login_menu').style.display = 'none';
	$('register_menu').style.display = 'table-row';
	$('chat_menu').style.display = 'none';
	$('contacts_menu').style.display = 'none';
	$('help_menu_0').style.display = 'none';
	$('help_menu_1').style.display = 'none';
	
	$('login-tbl').style.display = 'none';
	$('reg-tbl').style.display = 'table';
	$('chat-tbl').style.display = 'none';
	$('contacts-tbl').style.display = 'none';
	$('help-tbl').style.display = 'none';
//	$('td-error').innerHTML = "";
}

function gotoContacts() {
	var contact = {id:user,status:"on"};
	first_time_link(contact);
	refresh_contacts();
}

function refresh_contacts() {
	get_contacts();

	$('login_menu').style.display = 'none';
	$('register_menu').style.display = 'none';
	$('chat_menu').style.display = 'none';
	$('contacts_menu').style.display = 'table-row';
	$('help_menu_0').style.display = 'none';
	$('help_menu_1').style.display = 'none';
	
	$('login-tbl').style.display = 'none';
	$('reg-tbl').style.display = 'none';
	$('chat-tbl').style.display = 'none';
	$('contacts-tbl').style.display = 'table';
	$('help-tbl').style.display = 'none';
}

function confirm_contact_remove(contact_id) {
	new ConfirmBox(contact_id);
}

function confirm_yes(contact_id) {
//	alert("Remove "+contact_id);
	remove_contact(contact_id);
	websocketclient.unsubscribe(contact_id);
}

function confirm_no() {	
}

function gotoChatbyClick(contact) {
	console.log("gotoChatbyClick: contact id= " + contact);
//	$('login-tbl').style.display = 'none';
//	$('reg-tbl').style.display = 'none';
//	$('chat-tbl').style.display = 'table';
//	$('contacts-tbl').style.display = 'none';
//	$('help-tbl').style.display = 'none';
//	$('td-error').innerHTML = "Chat";
	var contacts = contacts_board.contacts;
	if (!contacts.some(function (element, index, array) { return (element.id == contact);})) {
		contacts.push({id:contact,status:"on"});
	}
//	link({id:contact,status:"on"}, contacts);
	gotoChat({id:contact,status:"on"}, contacts)
}

function gotoChatTest() {
	console.log(">>> gotoChatTest");
	$('login_menu').style.display = 'none';
	$('register_menu').style.display = 'none';
	$('chat_menu').style.display = 'table-row';
	$('contacts_menu').style.display = 'none';
	$('help_menu_0').style.display = 'none';
	$('help_menu_1').style.display = 'none';
	
	$('login-tbl').style.display = 'none';
	$('reg-tbl').style.display = 'none';
	$('chat-tbl').style.display = 'table';
	$('contacts-tbl').style.display = 'none';
	$('help-tbl').style.display = 'none';
}

function gotoChat(contact, ContactList) {
	console.log("gotoChat: contact id= " + contact.id);

	$('login_menu').style.display = 'none';
	$('register_menu').style.display = 'none';
	$('chat_menu').style.display = 'table-row';
	$('contacts_menu').style.display = 'none';
	$('help_menu_0').style.display = 'none';
	$('help_menu_1').style.display = 'none';
	
	$('login-tbl').style.display = 'none';
	$('reg-tbl').style.display = 'none';
	$('chat-tbl').style.display = 'table';
	$('contacts-tbl').style.display = 'none';
	$('help-tbl').style.display = 'none';
//	$('td-error').innerHTML = "Chat";
	link(contact, ContactList);
}

function change_contact(sender) {
	console.log("change_contact: sender= " + sender);
	var search = websocketclient.contacts.filter(function(contact){/*console.log("filter: " + contact);*/ return contact.id === sender});
	console.log("change_contact: search= " + search);
	if (search.length == 0) {
		console.log("change_contact: contact " + sender + " is not in your contact list.");
	} else {
		reLink(search[0]);
	}
}

function make_logout() {
	board.clear();
	contacts_board.clear();
}

function gotoHelp(menuIdx) {
	$('login_menu').style.display = 'none';
	$('register_menu').style.display = 'none';
	$('chat_menu').style.display = 'none';
	$('contacts_menu').style.display = 'none';
	if (menuIdx == 0) {
		$('help_menu_0').style.display = "table-row"
		$('help_menu_1').style.display = "none"
	} else if(menuIdx == 1) {
		$('help_menu_0').style.display = "none"
		$('help_menu_1').style.display = "table-row"
	}

	$('login-tbl').style.display = 'none';
	$('reg-tbl').style.display = 'none';
	$('chat-tbl').style.display = 'none';
	$('contacts-tbl').style.display = 'none';
	$('help-tbl').style.display = 'table';
//	$('td-error').innerHTML = "Help";
}

function parse_contacts(contacts) {
	return contacts.map(function(element, index, array) { return element.id;});
}
