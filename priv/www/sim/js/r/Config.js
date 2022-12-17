'use strict';

class Config {

	constructor() {
	}

	static mqtt_host;
	static mqtt_port;
	static mqtt_ssl;

	static {
		this.mqtt_host = "localhost";
		this.mqtt_port = 8880;
		this.mqtt_ssl = false;
	}
}