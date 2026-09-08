'use strict';

class RestAPI {

	constructor() {
	}
	
	static loginRequest(state, handleSuccess, handleError) {
		console.log('userName=' + state.userName + 'password=' + state.password);
		let myHeaders = new Headers();
		myHeaders.append('Accept', 'application/json');
		myHeaders.append('authorization', 'sim-web');
		let req = new Request('/sim/users?userName=' + state.userName + '&password=' + state.password, {
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
	
	static checkSession(handleSuccess, handleError) {
		let myHeaders = new Headers();
		myHeaders.append('Accept', 'application/json');
		myHeaders.append('authorization', 'sim-web');
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
		myHeaders.append('Content-Type', 'application/json');
		myHeaders.append('authorization', 'sim-web');
		let req = new Request('/sim/users', {
			method: 'POST', 
			headers: myHeaders, 
			body: '{"userName": "' + state.userName + '","password": "' + state.password1 +'"}'
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
		myHeaders.append('authorization', 'sim-web');
		let req = new Request('/sim/users/' + user + '/contacts', {
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
		myHeaders.append('Content-Type', 'application/json');
		myHeaders.append('authorization', 'sim-web');
		let req = new Request('/sim/users/' + user + '/contacts', {
			method: 'POST', 
			headers: myHeaders,
			body: '{"contactName":"' + new_contact + '"}'
			});
		fetch(req)
			.then(res => res.json())
			.then(json => handleSuccess(json, new_contact))
			.catch(err => handleError(err));
	}
	
	static remove_contact(user, contact, handleSuccess, handleError) {
		let myHeaders = new Headers();
		myHeaders.append('Accept', 'application/json');
		myHeaders.append('Content-Type', 'application/json');
		myHeaders.append('authorization', 'sim-web');
		let req = new Request('/sim/users/' + user + '/contacts', {
			method: 'DELETE', 
			headers: myHeaders,
			body: '{"contactName": "' + contact + '"}'
			});
		fetch(req)
			.then(res => res.json())
			.then(json => handleSuccess(json, contact))
			.catch(err => handleError(err));
	}
}

