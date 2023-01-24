'use strict';

class LandingPage extends React.Component {

	constructor(props) {
		super(props);
		this.state = {};
	}

	getHtmlText() {
		return `<h4>Slack and austere instant messenger (SIM)</h4>
				<h5>Features:</h5>
			<p>
				1. Anonymous registration: user does not need to link your account to e-mail or phone number.
			</p>
			<p>
				2. SIM client is web browser application that is running on desktop computer, laptop, 
				tablet or phone the same way. And there are no App stores, no upgrade/download.
			</p>
			<p>
				3. The messenger is using MQTT protokol to exchange messages. Central broker is implemented
				as MQTT server <a href ="https://github.com/alekras/erl.mqtt.server">github.com/alekras/erl.mqtt.server</a>
			</p>
			<p>
				4. SIM does not keep history of messages on server side. Messages on client side 
				are saved in session store and after user logout are gone.
			</p>
			<p>
				5. Connections between clients are established using TLS (SSL) encryption.
			</p>
			<p>
				6. SIM is open source project <a href="https://github.com/alekras/erl.web.sim">github.com/alekras/erl.web.sim</a>.
				If you are familiar with software development you can deploy your own SIM web and MQTT server.
			</p>
			<p>
				7. Let\'s start by clicking on "Register" menu item above.
			</p>
			`;
	}

	render() {
		return e(
			'div',
			{
				className:'help',
				dangerouslySetInnerHTML:{ __html: this.getHtmlText() }
			}
		);
	}
}