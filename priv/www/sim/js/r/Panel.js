'use strict';

class Panel extends React.Component {
	constructor(props) {
		super(props);
		this.state = {
			activeMenu: 'Land',
			board: 'Land',
			user: undefined,
			pw: undefined,
			connected:false,
			connectedTo:'',
			auth:false
		};
		RestAPI.checkSession(this.handleCheckSessionSuccess, this.handleCheckSessionError);
		this.parentTd = React.createRef();
		this.warnBoxRef = undefined;
	}
	
	handleCheckSessionSuccess = (json) => {
		console.log('Response GET -> session:: ' + JSON.stringify(json));
		if (json.session) {
			this.handleStateChange(true, json.session.user, json.session.password);
			var messageList = window.sessionStorage.getItem('messageList');
			if (messageList) {
				BoardChat.messageList = JSON.parse(messageList);
			} else {
				BoardChat.messageList = [];
			}
		} else {
			console.log('Cannot retrive session object...')
		}
	}
	
	handleCheckSessionError = (error) => {
		console.log('Error during get session check')
	}

	handleMouseClickMenu(event, command) {
		console.log('Click on ' + command);
		if (command == 'Logout') {
			if (BoardChat.mqttClient) {
				BoardChat.mqttClient.disconnect();
				delete BoardChat.mqttClient;
			}
			BoardChat.messageList = [];
			this.deleteCookie('sessionid');
			window.sessionStorage.removeItem('messageList');
			this.setState({
				auth:false,
				activeMenu:'Land',
				board:'Land',
				user:undefined
			});
		} else {
			this.setState({activeMenu: command, connectedTo:this.state.user});
		}
	}

	deleteCookie(name) {
//		console.log('1.Cookie = ' + document.cookie);
		document.cookie = name + '=; expires=Thu, 01 Jan 1970 00:00:01 GMT;path=/sim;';
//		console.log('2.Cookie = ' + document.cookie);
	}

	handleStateChange = (auth, un, pw) => {
//		console.log('State change: ' + JSON.stringify(this.state) 
//				+ ' auth: ' + auth + ' un: ' + un + ' pw: ' + pw);
		if (auth) {
			this.createMQTTClient(un, pw);
//			BoardChat.mqttClient.connect();
			this.setState({
				auth:true,
				activeMenu:'Contacts',
				board:'Contacts',
				user: un,
				pw: pw
			});
		} else {
			if (BoardChat.mqttClient) {
				BoardChat.mqttClient.disconnect();
				delete BoardChat.mqttClient;
			}
			this.setState({
				auth:false,
				activeMenu:'Login',
				board:'Login',
				user: undefined,
				pw: undefined
			});
		};
	}
	
	createMQTTClient = (userName, password) => {
		if (!BoardChat.mqttClient) {
			BoardChat.mqttClient = new MQTTClient({
				host: Config.mqtt_host,
				port: Config.mqtt_port,
				ssl: Config.mqtt_ssl,
				user: userName,
				password: password
			});
		}
		BoardChat.mqttClient.afterMsgArrive = () => {};
		BoardChat.mqttClient.afterConnectionStateChanged = (isConnected) => {
			this.setState({connected:isConnected});
		};
	}
	
	handleStateChangeReg = (success) => {
//		console.log('State change Reg: ' + JSON.stringify(this.state));
		if (success) {
			this.setState({
				auth:false,
				activeMenu:'Login',
				board:'Login'
			});
		} else {
			this.setState({
				auth:false,
				activeMenu:'Register',
				board:'Register'
			});
		};
	}

	handleMoveToChat = (e, contact) => {
		this.setState({
			connectedTo:contact,
			activeMenu:'Chat',
			board:'Chat'
		});
	}

	render() {
		var board;
		switch (this.state.activeMenu) {
			case 'Login' :
				board = e(BoardLogin, 
					{
						parent:this.parentTd,
						warnBox:this.warnBoxRef,
						onStateChange:this.handleStateChange
					});
				break;
			case 'Register' :
				board = e(BoardRegister,
					{
						parent:this.parentTd,
						warnBox:this.warnBoxRef,
						onStateChange:this.handleStateChangeReg
					});
				break;
			case 'Help' :
				board = e(BoardHelp, {key:1});
				break;
			case 'Contacts' :
				board = e(BoardContacts,
					{
						parent:this.parentTd,
						warnBox:this.warnBoxRef,
						onMoveToChat:this.handleMoveToChat,
						user:this.state.user
					});
				break;
			case 'Chat' :
				board = e(BoardChat, 
						{	key: 1, 
							user:this.state.user, 
							password:this.state.pw, 
							contact:this.state.connectedTo,
							w:this.props.w,
							h:this.props.h
						},
						null);
				break;
			case 'Logout' :
				board = e(LandingPage, {key: 1}, null);
				break;
			default : 
				board = e(LandingPage, {key: 1}, null);
				break;
		}
		return e('table', 
			{
				className:'table',
				style:{width:this.props.w, height:this.props.h}
			},
			e('tbody', {}, [
				e('tr', {align:"center", key: 1}, [
					e('td', {key: 1, colSpan:'4', className:'title'}, [
						e(Title, {key: 1, user:this.state.user, connected:this.state.connected})
					])
				]),
				e('tr', {align:"center", className:'menu', key: 2},
					e(Menu, 
					{
						key: 1,
						onMenuClick:(event, command) => this.handleMouseClickMenu(event, command),
						state: this.state.auth,
						active: this.state.activeMenu
					})
				),
				e('tr', {align:"center", key: 3},
					e('td', 
						{
							ref:this.parentTd,
							className:'board-container',
							colSpan:'4'
						}, board
					)
				),
				e('tr', {key: 4},
					e('td', {key: 1, colSpan:'4', style:{height: '10px'}}, [
						e('div',
							{
								id: 'copyright',
								className: 'copyright',
								key: 1
							},
							`©AKrasnopolski 2022 v 0.0.2 (React)`
						),
						e(WarningBox, {
								key:2,
								ref:(instance) => {this.warnBoxRef = instance;}
						})
					]),
				)
//				e('tr', {key:5}, 
//					e('td', {key:1, colSpan:'4', style:{display: 'none'}}, 
//						e(WarningBox, {
//								key:1,
//								ref:(instance) => {this.warnBoxRef = instance;}
//						})
//					)
//				)
			]
		))
	}
}