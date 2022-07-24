#!/bin/sh

export PATH="$PATH:/usr/local/bin:/usr/local/Cellar/erlang/23.0/lib/erlang/bin"
echo "argument: $1"
REBAR3="/opt/local/bin/rebar3"
$REBAR3 do version
$REBAR3 do upgrade

case "$1" in
	dev)
		$REBAR3 release -n sim_web_dev
		cd _build/default/rel/sim_web_dev/bin
		./sim_web_dev start
		./sim_web_dev pid
		;;
	prod)
		$REBAR3 release -n sim_web
		cd _build/default/rel/sim_web/bin
		./sim_web start
		./sim_web pid
		;;
	*)
		echo "Usage: $0 [dev|prod]"
		;;
esac

exit 0
