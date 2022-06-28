#!/bin/sh
#    -detached \

/opt/local/bin/rebar3 do version,compile

erl -pa _build/default/lib/*/ebin \
  -boot start_sasl \
  -config sim_web \
  -s ssl \
  -s inets \
  -name sim_web_server@localhost \
  -eval "application:ensure_all_started(sim_web)" \
  -setcookie 'web'
