export DETS_DIR="/private/var/data/dets-storage"
export PORT_REST=8000
export PORT_MQTT_WS=8880
export PORT_MQTT_REST=8080

echo "arguments: $1 (dev | prod)"
case "$1" in
	dev)
		export HOST_MQTT="MACBOOK-PRO"
		RELEASE_NAME="sim_web_dev"
		;;
	prod)
		export HOST_MQTT="localhost"
		RELEASE_NAME="sim_web"
		;;
	*)
		echo "Usage: $0 [dev|prod]"
		exit 1
		;;
esac

docker run -it \
 -p "$PORT_REST":"$PORT_REST"/tcp \
 --name docker_container_sim \
 --hostname localhost \
 --net mqtt_net \
 --rm \
 -e HOST_MQTT="$HOST_MQTT" \
 -e PORT_MQTT_REST="$PORT_MQTT_REST" \
 -e PORT_REST="$PORT_REST" \
 -e PORT_MQTT_WS="$PORT_MQTT_WS" \
 -e NODE_NAME=sim_web \
 -e DETS_DIR="$DETS_DIR" \
 --mount type=bind,src="/private/var/data/dets-storage",dst="$DETS_DIR" \
 $RELEASE_NAME
