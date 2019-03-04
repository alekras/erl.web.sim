#!/bin/sh
#    -detached \

C:\Users\axk456\Applications\erlang\bin\werl ^
-pa ^
_build\default\lib\cowboy\ebin ^
_build\default\lib\cowlib\ebin ^
_build\default\lib\goldrush\ebin ^
_build\default\lib\lager\ebin ^
_build\default\lib\mysql_client\ebin ^
_build\default\lib\ranch\ebin ^
_build\default\lib\rsrc_pool\ebin ^
_build\default\lib\sim_web\ebin ^
-boot start_sasl ^
-config sim_web ^
-s ssl ^
-s inets ^
-name sim_web_server@localhost ^
-eval "application:start(sim_web)" ^
-setcookie 'web'
  