/**
 * 
 */
'use strict';

class BoardHelp extends React.Component {
	constructor(props) {
		super(props);
		this.state = {};
	}
	
	getHtmlText() {
		return `<h3>1. Lets getting starting.</h3>
			<p>
			  First you need to register with the messenger. Go to landing page and in main menu click on tab "Register". Then type 
			  your user name and password (two times for confirmation). Your partner needs to register too and 
			  to share his/her user name with you. 
			</p>
			<p>
				You need to login after registration. Use "Login" tab in main menu for this.
				After successful login you come to "Contacts" tab. Now you need to add your partner user name
				to the contacts list. Type the user name in text box and click <img src="/sim/img/add-user.png" style="height: 25px;vertical-align: middle;"> button.
				This is important to create contacts list. You can send or receive messages from your partner only if the partner was added to contact list.
				If you like to remove some contact from list just click on button <img src="/sim/img/remove-user.png" style="height: 25px;vertical-align: middle;">
			</p>
			<p>
				You can send messages to your partner now. Click on contact\'s name and messenger will switch to "Chat" tab.
			</p>
			<p>
				Now you can type message in text area and click send button <img src="/sim/img/send.png" style="height: 25px;vertical-align: middle;">
				Message will go to your communication partner. You can see sent messages with timestamp in message board below.
			</p>
			<p>
				When your partner responses with a message then the partner\'s message will appear in the message board just below your message.
				If you send message when the partner is disconnected then the message will be stored on server while your partner becomes online. 
				In this moment your message will arrive to destination. The same will be happened if you was offline when your partner sent message.
				You do not miss the message but receive it in next time you login to messenger. 
			</p>`;
	}
	
	render() {
		return e(
			'div',
			{
				className:'help',
				dangerouslySetInnerHTML:{ __html: this.getHtmlText() }
			}
		)
	}
}