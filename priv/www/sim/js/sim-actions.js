var user,
	user_password, 
	link_header, 
	send_footer, 
	board, 
	contacts_board;

function init() {
	console.log(">>> init()");
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
}

function gotoAfterSuccessLogin(p_user, p_user_password) {
	user = p_user;
	user_password = p_user_password;
	websocketclient.create(mqtt_host, mqtt_port, mqtt_ssl, user, user_password);
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
}

function gotoContacts() {
	var contact = user;
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
	var contacts = contacts_board.contacts;
	if (!contacts[contact]) {
//		contacts.push(contact);
	}
	gotoChat(contact)
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

function gotoChat(contact) {
	console.log("gotoChat: contact id= " + contact);

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
	link(contact);
}

function change_contact(sender) {
	console.log("change_contact: sender= " + sender);
	var search = websocketclient.contacts[sender];
	console.log("change_contact: search= " + search);
	if (!search) {
		console.log("change_contact: contact " + sender + " is not in your contact list.");
	} else {
		reLink(sender);
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
}

//function parse_contacts(contacts) {
//	return contacts.map(function(element, index, array) { return element.id;});
//}
