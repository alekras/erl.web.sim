/**
 * 
 */
'use strict';

class BoardChat extends React.Component {
	constructor(props) {
		super(props);
		this.state = {
			messageToSend:'',
			currentContact:this.props.contact
		};
		if (BoardChat.mqttClient) {
			BoardChat.mqttClient.afterMsgArrive = this.refreshAfterMsgArrived;
			BoardChat.mqttClient.connect();
			BoardChat.mqttClient.contact = this.state.currentContact;
		} else {
			console.log('<<< BoardChat constructor:: BoardChat.mqttClient does not exist');
		}
		console.log('<<< BoardChat constructor. currentContact:' + this.state.currentContact);
	}
	
	static mqttClient;
	static messageList = [];
	
	handleChange(event) {
		this.setState({messageToSend:event.target.value});
//		console.log('Event comes:: ' + event.target.value + ', ' + event.target.name)
		event.preventDefault();
	}
	
	clickToSend = (event) => {
		var timeStamp = moment().format('MM-DD-YY HH:mm');
		console.log('Message to send:: ' + this.state.messageToSend);
		BoardChat.mqttClient.send({msg:this.state.messageToSend, time:timeStamp});
		var txt = this.state.messageToSend.replace(/ /g, '&nbsp;').replace(/\n/g, '<br>');
		BoardChat.messageList.push({msg:txt, time:timeStamp, 
			type:'out', sender:this.props.user});
		this.setState({messageToSend:''});
	}
	
	// TODO: need to sort by time retained messages after relogin
	static onMessageArrived(payloadString, contact) {
//		console.log('BoardChat::onMessageArrived >>> ' + contact);
		var payload = JSON.parse(payloadString);
//		var sound = $('audio-newmsg');
//		try {
//			sound.play();
//		} catch (e) {
//			console.log(e);
//		}
		var txt = payload.msg.replace(/ /g, '&nbsp;').replace(/\n/g, '<br>');
		BoardChat.messageList.push({msg:txt, time:payload.time,
			type:'in', sender:contact});
		window.sessionStorage.setItem('messageList', JSON.stringify(BoardChat.messageList));
	}
	
	refreshAfterMsgArrived = () => {
		this.setState({messageToSend:''});
	}
	
	handleChangeContact = (e, newContact) => {
		BoardChat.mqttClient.contact = newContact;
		this.setState({currentContact:newContact});
	}
	
	shouldComponentUpdate(nextProps, nextState) {
		if (this.state !== nextState) {
			return true;
		}
		return false;
	}

	render() {
//		console.log('>>> BoardChat render(). Component state:' + JSON.stringify(this.state));
		let i = 0;
		let rows = BoardChat.messageList.map((member) => {
			i++;
//			console.log('i:' + i + ' member:' + JSON.stringify(member));
			return e(Message, {key:i, 
				item:member,
				changeContact:this.handleChangeContact
			});
		});
		
		let bgColor;
		if (this.props.user == this.state.currentContact) {
			bgColor = 'Aquamarine';
		} else {
			let status = BoardContacts.contacts[this.state.currentContact].status;
			if (status == 'on') {
				bgColor = 'Aquamarine';
			} else if (status == 'off') {
				bgColor = 'LightSalmon';
			} else {
				bgColor = 'LightSalmon';
			}
		}
		
		return e(
			'table',
			{
				className:'tbl_chat'
				//style:{maxWidth:this.props.w}
			}, 
			e('tbody', {key:1}, [
				e('tr', {key:1}, [
					e('td', {key:1, colSpan:'2', style:{height:'100%'}}, 
						[e('div', {key:1, className:'board_chat'}, rows)])
				]),
				e('tr', {key:0}, [
					e('td', {key:1, colSpan:'2', style:{height:'15px', backgroundColor:'white'}}, [
						e('span', {key:1, style:{paddingLeft:'20px', fontWeight: 'bold'}}, 'Sending message to '),
						e('span', {key:2, style:{backgroundColor:bgColor}}, this.state.currentContact)
					])
				]),
				e('tr', {key:2, style:{backgroundColor:'rgb(156,222,228)'}}, [
					e('td', {key:1, style:{height:'62px'}}, 
						e('textarea', {key:1,
							className:'text-area',
							onChange:(e)=>this.handleChange(e),
							value:this.state.messageToSend})
					),
					e('td', {key:2, style:{width:'61px'}}, 
						e('span', {key:1,
							className:'button btn-send',
							onClick:(e)=>this.clickToSend(e)}, 'Send'))
				])
			])
		);
	}
}

class Message extends React.Component {
	constructor(props) {
		super(props);
		this.state = {};
	}
	
	render() {
		switch (this.props.item.type) {
			case 'in': 
				return e('div', {}, [
					e('div', {key:0, 
						className:'sender',
						onClick:(e)=>this.props.changeContact(e, this.props.item.sender)
					}, this.props.item.sender + ':'),
					e('div', {key:1, className:'right-msg'}, [
						e('div', {key:0, className:'text-msg', 
								dangerouslySetInnerHTML:{ __html: this.props.item.msg}},
							null),
						e('div', {key:1, className:'text-timestamp'}, this.props.item.time)
					]),
					e('div', {key:2, style:{clear:'both'}})
				]);
			case 'out': 
				return e('div', {}, [
					e('div', {key:0, className:'left-msg'}, [
						e('div', {key:0, className:'text-msg',
								dangerouslySetInnerHTML:{ __html: this.props.item.msg}},
							null),
						e('div', {key:1, className:'text-timestamp'}, this.props.item.time)
					]),
					e('div', {key:1, style:{clear:'both'}})
				]);
			default:
				return null;
		}
	}
}
