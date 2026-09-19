#!/bin/sh

export PATH="$PATH:/usr/bin:/usr/local/bin:/usr/local/Cellar/erlang/28.0.2_1/bin"
export DETS_DIR=/private/var/data/dets-storage
export PORT_REST=8000
export PORT_MQTT_WS=8880
export PORT_MQTT_REST=8080

echo "arguments: $1 $2"

case "$1" in
	dev)
		cd _build/default/rel/sim_web_dev
		export HOST_MQTT=MACBOOK-PRO
		SCRIPT_NAME="./bin/sim_web_dev"
		;;
	prod)
		cd _build/default/rel/sim_web
		export HOST_MQTT=localhost
		SCRIPT_NAME="./bin/sim_web"
		;;
	*)
		echo "Usage: $0 [dev|prod] [start|stop|console]"
		exit 1
		;;
esac

case "$2" in
	start)
		$SCRIPT_NAME daemon
		sleep 2
		$SCRIPT_NAME pid
		;;
	stop)
		$SCRIPT_NAME stop
		$SCRIPT_NAME status
		;;
	console)
		$SCRIPT_NAME console
		;;
	*)
		echo "Usage: $0 [dev|prod] [start|stop|console]"
		;;
esac

exit 0
