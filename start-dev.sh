#!/bin/sh
#    -detached \

erl -pa _build/default/lib/*/ebin \
  -boot start_sasl \
  -config sim_web \
  -s ssl \
  -s inets \
  -name sim_web_server@localhost \
  -eval "application:start(sim_web)" \
  -setcookie 'web'
