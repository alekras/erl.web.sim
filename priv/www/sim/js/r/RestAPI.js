'use strict';

class RestAPI {

	constructor() {
	}
	
	static loginRequest(state, handleSuccess, handleError) {
		console.log('userName=' + state.userName + 'password=' + state.password);
		let myHeaders = new Headers();
		myHeaders.append('Accept', 'application/json');
		let req = new Request('/sim/login', {
			method: 'POST', 
			headers: myHeaders, 
			body: 'user=' + state.userName + '&password=' + state.password
			});
		fetch(req)
			.then(res => res.json())
			.then(
				handleSuccess,
				handleError
			);
	}
	
	static checkSession(handleSuccess, handleError) {
		let myHeaders = new Headers();
		myHeaders.append('Accept', 'application/json');
		let req = new Request('/sim/checksession', {
			method: 'GET', 
			headers: myHeaders
			});
		fetch(req)
			.then(res => res.json())
			.then(json => handleSuccess(json))
			.catch(err => handleError(err));
	}
	
	static registerRequest(state, handleSuccess, handleError) {
		let myHeaders = new Headers();
		myHeaders.append('Accept', 'application/json');
		let req = new Request('/sim/register', {
			method: 'POST', 
			headers: myHeaders, 
			body: 'user=' + state.userName 
				+ '&password1=' + state.password1 
				+ '&password2=' + state.password2
			});
		fetch(req)
			.then(res => res.json())
			.then(
				handleSuccess,
				handleError
			);
	}
	
	static getContacts(user, handleSuccess, handleError) {
		let myHeaders = new Headers();
		myHeaders.append('Accept', 'application/json');
		let req = new Request('/sim/contacts/' + user + '/get_all', {
			method: 'GET', 
			headers: myHeaders
			});
		fetch(req)
			.then(res => res.json())
			.then(
				handleSuccess,
				handleError
			);
	}
	
	static add_contact(user, new_contact, handleSuccess, handleError) {
//		console.log('new contact=' + new_contact);
		let myHeaders = new Headers();
		myHeaders.append('Accept', 'application/json');
		let req = new Request('/sim/contacts/' + user + '/add/' + new_contact, {
			method: 'POST', 
			headers: myHeaders,
			body: ''
			});
		fetch(req)
			.then(res => res.json())
			.then(json => handleSuccess(json, new_contact))
			.catch(err => handleError(err));
	}
	
	static remove_contact(user, contact, handleSuccess, handleError) {
		let myHeaders = new Headers();
		myHeaders.append('Accept', 'application/json');
		let req = new Request('/sim/contacts/' + user + '/remove/' + contact, {
			method: 'POST', 
			headers: myHeaders,
			body: ''
			});
		fetch(req)
			.then(res => res.json())
			.then(json => handleSuccess(json, contact))
			.catch(err => handleError(err));
	}
}

