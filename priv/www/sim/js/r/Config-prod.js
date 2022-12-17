'use strict';

class Config {

	constructor() {
	}

	static mqtt_host;
	static mqtt_port;
	static mqtt_ssl;

	static {
		this.mqtt_host = "lucky3p.com";
		this.mqtt_port = 4443;
		this.mqtt_ssl = true;
	}
}