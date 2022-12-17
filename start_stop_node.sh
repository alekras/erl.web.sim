#!/bin/sh

export PATH="$PATH:/usr/local/bin:/usr/local/Cellar/erlang/23.0/lib/erlang/bin"
echo "arguments: $1 $2"
REBAR3="/opt/local/bin/rebar3"
$REBAR3 do version


case "$1" in
	dev)
		cd _build/default/rel/sim_web_dev
		SCRIPT_NAME="./bin/sim_web_dev"
		;;
	prod)
		cd _build/default/rel/sim_web
		SCRIPT_NAME="./bin/sim_web"
		;;
	*)
		echo "Usage: $0 [dev|prod] [start|stop|console]"
		;;
esac

case "$2" in
	start)
		$SCRIPT_NAME start
		$SCRIPT_NAME pid
		;;
	stop)
		$SCRIPT_NAME stop
		;;
	console)
		$SCRIPT_NAME console
		;;
	*)
		echo "Usage: $0 [dev|prod] [start|stop|console]"
		;;
esac

exit 0
