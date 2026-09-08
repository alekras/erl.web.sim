%%
%% Copyright (C) 2015-2026 by krasnop@bellsouth.net (Alexei Krasnopolski)
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%%     http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License. 
%%
-module(sim_web).
-behaviour(application).
-include("sim_web.hrl").

-export([start/2]).
-export([stop/1]).

start(_Type, _Args) ->
	Port = application:get_env(sim_web, port, 8001),
	lager:info([{endtype, server}], "Start SIM web app [ver: 2.0.1] with args: ~p, on Port:~p.~n", [_Args, Port]),	
	sim_dets_dao:start(),
	ets:new(sessionTable, [set, public, named_table, {keypos, #session.id}]),
	sim_web_server:start(sim_web, #{transport_opts => [{ip,{0,0,0,0}}, {port,Port}]}),
%% 	ChildSpec :: {Id :: term(), StartFunc, RestartPolicy, Shutdown, Type :: worker | supervisor, Modules},
%% 	StartFunc :: {M :: module(), F :: atom(), A :: [term()] | undefined},
%% 	RestartPolicy :: permanent
%% 				   | transient
%% 				   | temporary,
%% 	Shutdown :: brutal_kill | timeout(),
%% 	Modules :: [module()] | dynamic.
	EchoSpec = {
		echo_worker, 
		{sim_echo, start, []},
		permanent, 
		5000, 
		supervisor, 
		[sim_echo]
	},
	sim_sup:start_link([EchoSpec]).

stop(_State) ->
	sim_dets_dao:close(),
	ok = ranch:stop_listener(sim_web).
