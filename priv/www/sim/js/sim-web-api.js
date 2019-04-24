/* This is Restfull API
 * 
 */

/* request server to login user/password (DOM elements 'f1' and 'f2'). 
 * Input:
 *   element f1 - user;
 *   element f2 - password;
 * result action:
 *   set global vars user, password
 *   show chat-tbl
 * */
function doLoginRequest() {
	new Ajax.Request('/sim/login',{
		method: 'post',
		parameters: {user: $('f1').value, password: $('f2').value},
		requestHeaders: {Accept: 'application/json'},
		onSuccess: function(transport){
			console.log(transport.responseJSON.status);
			if (transport.responseJSON.status == 'ok') {
				var user = $('f1').value;
				var user_password = $('f2').value;
				gotoAfterSuccessLogin(user, user_password);
			} else {
				$('td-error').innerHTML = "User name or Password are invalid.<br/>Please try again.";
			}
		}
	});
}

/*
 * Send request to server for registration.
 */
function doRegisterRequest() {
	$('register').setAttribute("disabled", "disabled");
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
				$('td-error').innerHTML = "You are successfully registered";
				$('td-error').innerHTML = "You are successfully registered";
			} else {
				if (transport.responseJSON.reason == 'exist') {
					$('td-error').innerHTML = "This user name already exists.<br/>Please try another.";
				} else if (transport.responseJSON.reason == 'password') {
					$('td-error').innerHTML = "Password is too short or does not fit confirmed one.<br/>Please try again.";
				}
			}
		},
		
		onComplete: function(response) {
			$('register').removeAttribute("disabled");
		}
	});
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
//				contactNames = parse_contacts(transport.responseJSON.contacts);
//				contactNames.forEach(function(element, index, array) { console.log(index + ': ' + element);});
				render_contacts(transport.responseJSON.contacts);
				$('td-error').innerHTML = "You are successfully add new contact";
			} else {
				if (transport.responseJSON.reason == 'not_exist') {
					$('td-error').innerHTML = "This contact name does not exist.<br/>Please try another.";
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
//				contactNames = parse_contacts(transport.responseJSON.contacts);
//				contactNames.forEach(function(element, index, array) { console.log(index + ': ' + element);});
				render_contacts(transport.responseJSON.contacts);
				$('td-error').innerHTML = "You are successfully get all your contacts";
			} else {
				if (transport.responseJSON.reason == 'exist') {
					$('td-error').innerHTML = "Something wrong.";
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
//				contactNames = parse_contacts(transport.responseJSON.contacts);
//				contactNames.forEach(function(element, index, array) { console.log(index + ': ' + element);});
				render_contacts(transport.responseJSON.contacts);
				$('td-error').innerHTML = "You are successfully add new contact";
			} else {
				if (transport.responseJSON.reason == 'exist') {
					$('td-error').innerHTML = "This contact name does not exist.<br/>Please try another.";
				}
			}
		},
		
		onComplete: function(response) {
		}
	});
}
