#!/bin/sh

export PATH="$PATH:/usr/local/bin:/usr/local/Cellar/erlang/23.0/lib/erlang/bin"
echo "argument: $1"
REBAR3="/opt/local/bin/rebar3"
$REBAR3 do version
$REBAR3 do unlock
$REBAR3 do upgrade

case "$1" in
	dev)
		REL_NAME="sim_web_dev"
		;;
	prod)
		REL_NAME="sim_web"
		;;
	*)
		echo "Usage: $0 [dev|prod]"
		;;
esac

$REBAR3 release -n $REL_NAME
cd _build/default/rel/$REL_NAME
./bin/$REL_NAME start
sleep 2
./bin/$REL_NAME pid

exit 0
