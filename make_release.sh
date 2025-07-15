#!/bin/sh

## export PATH="$PATH:/usr/local/bin:/usr/local/Cellar/erlang/23.0/lib/erlang/bin"
export PATH="$PATH:/usr/local/Cellar/erlang@23/23.3.4.18/lib/erlang/bin"
echo "argument: $1"
REBAR3="/opt/local/bin/rebar3"
$REBAR3 do version
$REBAR3 do unlock --all
$REBAR3 do upgrade --all

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

exit 0
