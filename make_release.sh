#!/bin/sh

export PATH="$PATH:/usr/bin:/usr/local/bin:/usr/local/Cellar/erlang/28.0.2_1/bin"
echo "argument: $1"
REBAR3="/opt/local/bin/rebar3"
$REBAR3 version
$REBAR3 unlock --all
$REBAR3 upgrade --all

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
