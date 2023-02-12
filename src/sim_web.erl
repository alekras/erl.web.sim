%% @author alexei
%% @doc @todo Add description to sim_app.

-module(sim_web).
-behaviour(application).
-include("sim_web.hrl").

%% ====================================================================
%% API functions
%% ====================================================================
-export([
	start/2,
	stop/1
]).

start(_Type, _Args) ->
	Dispatch = cowboy_router:compile([
		{'_', [
			{"/sim-o", cowboy_static, {priv_file, sim_web, "www/sim/index.html"}},
			{"/sim", cowboy_static, {priv_file, sim_web, "www/sim/index-react.html"}},
			{"/sim/js/[...]", cowboy_static, {priv_dir, sim_web, "www/sim/js", [{mimetypes, cow_mimetypes, all}]}},
			{"/sim/css/[...]", cowboy_static, {priv_dir, sim_web, "www/sim/css", [{mimetypes, cow_mimetypes, all}]}},
			{"/sim/img/[...]", cowboy_static, {priv_dir, sim_web, "www/sim/img", [{mimetypes, cow_mimetypes, all}]}},
			{"/sim/audio/[...]", cowboy_static, {priv_dir, sim_web, "www/sim/audio", [{mimetypes, cow_mimetypes, all}]}},
			{"/sim/checksession", sim_web_handler_check_session, []},
			{"/sim/login", sim_web_handler_log, []},
			{"/sim/register", sim_web_handler_reg, []},
			{"/sim/contacts/:user_name/get_all", sim_web_handler_cont, [get_all]},
			{"/sim/contacts/:user_name/add/:new_contact", sim_web_handler_cont, [add]},
			{"/sim/contacts/:user_name/remove/:contact_name", sim_web_handler_cont, [remove]}
		]}
	]),
	Port = application:get_env(sim_web, port, 8001),
	Host = application:get_env(sim_web, mqtt_rest_url, "http://localhost:18080"),
	{ok, _} = cowboy:start_clear(http, [{port, Port}], #{
		env => #{dispatch => Dispatch}
	}),
	sim_web_dets_dao:start(),
	ets:new(sessionTable, [set, public, named_table, {keypos, #session.id}]),
%%	sim_web_echo:start(),
	lager:info("Sim_web application is starting on port:~p; Rest Host url:~p~n", [Port, Host]),
%% 	ChildSpec :: {Id :: term(), StartFunc, RestartPolicy, Shutdown, Type :: worker | supervisor, Modules},
%% 	StartFunc :: {M :: module(), F :: atom(), A :: [term()] | undefined},
%% 	RestartPolicy :: permanent
%% 				   | transient
%% 				   | temporary,
%% 	Shutdown :: brutal_kill | timeout(),
%% 	Modules :: [module()] | dynamic.
	EchoSpec = {
		echo_worker, 
		{sim_web_echo, start, []},
		permanent, 
		5000, 
		supervisor, 
		[sim_web_echo]
	},
	sim_web_sup:start_link([EchoSpec]).

stop(_State) ->
	sim_web_dets_dao:close(),
	ok.

%% ====================================================================
%% Internal functions
%% ====================================================================

