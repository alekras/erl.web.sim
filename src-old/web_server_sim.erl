%%% These are convenience methods for starting / stopping client in
%%% development environment.  Actual starting/stopping will be in application
%%% module.

-module(web_server_sim).
%-include("client.hrl").

-export([start/0, stop/0, restart/0]).

-define(DEPS, [kernel, stdlib, sasl, asn1, inets, crypto]).

%% @doc start dependency apps and the main application for a dev environment.
%% @end
start() ->
  start_deps(),
  {ok, Pid} = start_httpd(),
	[io:format(user, "Regname: ~p~n", [Regname]) || Regname <- registered(), whereis(Regname) == Pid],
	Pid.

%% @doc stop the main app and deps
stop() ->
  Pid = whereis(httpd_instance_sup_80default),
	inets:stop(httpd, Pid)
%%  stop_deps()
.

%% @doc restart the main app (deps left alone)
restart() ->
  stop(),
  start().

%%
%% internal
%%

start_deps() ->
  lists:foreach(fun(Dep) ->
    ok = ensure_started(Dep)
  end, ?DEPS).

stop_deps() ->
  [application:stop(Dep) || Dep <- lists:reverse(?DEPS)].

ensure_started(App) ->
  case application:start(App) of
    ok -> ok;
    {error, {already_started, App}} -> ok
  end.

start_httpd() ->
  inets:start(httpd, [
    {modules, [
       mod_alias, 
       mod_auth, 
       mod_esi, 
       mod_actions, 
       mod_cgi, 
       mod_dir, 
       mod_get, 
       mod_head, 
       mod_log, 
       mod_disk_log
     ]
    },
%%    {port,8443},
    {port,8000},
    {server_name,"lucky3p.com"},
    {server_root,"private"},
    {document_root,"private/www"},
    {bind_address, any}, 
    {socket_type, ip_comm}, 
%%     {socket_type, {ssl, 
%% 			[{certfile, "private/ssl/server.crt"},
%% 			 {cacertfile, "private/ssl/rootCA.pem"}, 
%%        {keyfile, "private/ssl/server.key"},
%% 			 {verify, verify_none}]}
%% 		},
    {directory_index, ["index.html"]},
%%    {alias, {"/sim,", "sim/"}},
    {erl_script_alias, {"/sim/req", [im]}},
    {error_log, "logs/error.log"},
    {security_log, "logs/security.log"},
    {transfer_log, "logs/transfer.log"},
    {mime_types,[
       {"html","text/html"},
       {"css","text/css"},
       {"js","application/x-javascript"},
       {"json","application/json"}
     ]
    }
  ])
.
 