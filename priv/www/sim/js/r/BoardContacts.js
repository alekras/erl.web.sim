/**
 * 
 */
'use strict';

class BoardContacts extends React.Component {
	constructor(props) {
		super(props);
		this.parentTable = React.createRef();
		this.state = {
			newContact:''
		};
		if (BoardChat.mqttClient) {
			BoardChat.mqttClient.afterMsgArrive = () => {};
			BoardChat.mqttClient.connect();
		} else {
			console.log('<<< BoardContacts constructor:: BoardChat.mqttClient does not exist');
		}
		RestAPI.getContacts(this.props.user, this.handleSuccessContacts, this.handleErrorContacts);
	}
		
	static contacts = {};

	handleChange(event) {
		this.setState({newContact: event.target.value});
//		console.log('Event comes:: ' + event.target.value + ', ' + event.target.name 
//			 + ' current= ' + this.parentTable.current
//		);
		event.preventDefault();
	}

// TODO: user is off because connection is not established !!!
	handleSuccessContacts = (json) => {
		console.log('Response GET -> contacts:: ' + JSON.stringify(json.contacts));
		if (json.status == 'ok') {
			BoardContacts.contacts = json.contacts;
			if (BoardChat.mqttClient) {
				BoardChat.mqttClient.onReady(true);
			}
			this.setState({}); // TODO: avoid if the component is not active (componentWillUnmount)
		} else {
			console.log('Cannot retrive contacts...')
		}
	}
	
	handleErrorContacts = (error) => {
		console.log('Error during get contacts')
	}
	
	clickToAdd = (event) => {
		if(this.state.newContact.trim().length == 0) {
			this.warnBoxRef.setLayout('warn', 'Contact name to add is empty.', this.parentTable.current.getBoundingClientRect());
			return;
		}
		if (BoardContacts.contacts[this.state.newContact]) {
			this.warnBoxRef.setLayout('warn', 'Contact name "' + this.state.newContact + '" to add is duplicate.', this.parentTable.current.getBoundingClientRect());
			return;
		}
		
		RestAPI.add_contact(
			this.props.user, 
			this.state.newContact, 
			this.handleSuccessAddContact, 
			this.handleErrorAddContact);
		this.setState({});
	}
	
	handleSuccessAddContact = (json, newContact) => {
		console.log('Response Add -> contacts:: ' + JSON.stringify(json));
		if (json.status == 'ok') {
			BoardContacts.contacts = json.contacts;
			this.warnBoxRef.setLayout(
				'warn',
				'You are successfully add new contact "' + this.state.newContact + '".',
				this.parentTable.current.getBoundingClientRect()
			);
//			console.log('Successfully add new contact')
			BoardChat.mqttClient.subscribe(newContact);
			this.setState({newContact:''});
		} 
		if (json.status == 'fail' && json.reason == 'notFound') {
			this.warnBoxRef.setLayout(
				'warn',
				'This contact name "' + this.state.newContact + '"does not exist. Please try another.',
				this.parentTable.current.getBoundingClientRect()
			);
		}
	}
	
	handleErrorAddContact = (error) => {
		console.log('Error during add new contact')
	}
	
	clickToRefresh = (event) => {
		RestAPI.getContacts(this.props.user, this.handleSuccessContacts, this.handleErrorContacts);
		this.setState({newContact:''});
	}
	
	clickToRemove = (event, contactName) => {
		this.warnBoxRef.setLayout(
			'confirm',
			'Do you want to remove "' + contactName + '" from your contacts list?',
			this.parentTable.current.getBoundingClientRect(),
			(arg) => {
				if (arg) {
					RestAPI.remove_contact(
					this.props.user, 
					contactName, 
					this.handleSuccessRemoveContact, 
					this.handleErrorRemoveContact)
				}
			} 
		);

	}
	
	handleSuccessRemoveContact = (json, contact) => {
		console.log('Response Remove -> contacts:: ' + JSON.stringify(json.contacts));
		if (json.status == 'ok') {
			BoardContacts.contacts = json.contacts;
			BoardChat.mqttClient.unsubscribe(contact);
			this.setState({});
			console.log('Successfully remove contact')
		} else {
			console.log('Cannot remove contact.')
		}
	}
	
	handleErrorRemoveContact = (error) => {
		console.log('Error during remove contact')
	}
	
	shouldComponentUpdate(nextProps, nextState) {
		if (this.state !== nextState) {
			return true;
		}
		return false;
	}

	renderControlHeader() {
		return e('tr', {key:0, align:'center', style:{backgroundColor:'rgb(156,222,228)'}}, [
			e('td', {key:1, className:'td-contacts-header'}, 
				e('div', {key:1,
					className:'button btn-add',
					onClick:(e)=>this.clickToAdd(e)
				})
			),
			e('td', {key:2}, 
				e('input', {key:1,
					className:'text-input',
					placeholder:'Contact id to add',
					onChange:(e)=>this.handleChange(e),
					value:this.state.newContact
				})
			),
			e('td', {key:3, className:'td-contacts-header'}, 
				e('div', {key:1,
					className:'button btn-refresh',
					onClick:(e)=>this.clickToRefresh(e)}
				)
			)
		]);
	}
	
	renderContactsBoard() {
		let i = 0;
		let rows = Object.entries(BoardContacts.contacts).map(([contactName, value]) => {
			i++;
	//		console.log('i:' + i + ' name:' + contactName + ' status:' + value.status);
			return e(Record, {key:i,
				contact:contactName,
				status:value.status,
				onMoveToChat:this.props.onMoveToChat,
				clickToRemove:this.clickToRemove});
		});
		
		return e('tr', {key:1}, [
			e('td', {key:1, colSpan:'3', className:'td-contacts-record'}, 
				e('div', {key:1,
					className:'board_chat'
				}, rows)
			)
		]);
	}
	
	render() {
		return e(
			'table',
			{
				className:'tbl_contacts',
				ref:this.parentTable
			}, 
			e('tbody', {key:1}, [
				this.renderControlHeader(),
				this.renderContactsBoard(),
				e('tr', {key:2}, 
					e('td', {key:1, colSpan:'3', className:''}, 
						e(WarningBox, {
								key:1,
								ref:(instance) => {this.warnBoxRef = instance;
							}
						})
					)
				)
			])
		);
	}
}

class Record extends React.Component {
	constructor(props) {
		super(props);
		this.state = {};
	}
	
	render() {
		let status;
		let bgColor;
		if (this.props.status == 'on') {
			status = 'online';
			bgColor = 'Aquamarine';
		} else if (this.props.status == 'off') {
			status = 'offline';
			bgColor = 'LightSalmon';
		} else {
			status = 'not exist';
			bgColor = 'LightSalmon';
		}
		return e('div', {className:'contact-record'}, [
			e('div', {key:1,
				className:'button btn-remove',
				onClick:(e)=>this.props.clickToRemove(e, this.props.contact)
			}),
			e('div', {key:2,
				className:'contact-id-record',
				style:{backgroundColor:bgColor},
				onClick:(e)=>this.props.onMoveToChat(e, this.props.contact)
			}, this.props.contact),
			e('div', {key:3,
				className:'contact-status-record'
			}, status)
		]);
	}
}
