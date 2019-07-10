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
	stop/1,
	test_setup/0
]).

start(_Type, _Args) ->
	lager:start(),
	S1 = application:start(ranch),
	lager:info("App started : ~p", [S1]),
	S2 = application:start(cowlib),
	lager:info("App started : ~p", [S2]),
	S3 = application:start(cowboy),
	lager:info("App started : ~p", [S3]),
	lager:info("App started !", []),
	Dispatch = cowboy_router:compile([
		{'_', [
			{"/sim", cowboy_static, {priv_file, sim_web, "www/sim/index.html"}},
			{"/sim/js/[...]", cowboy_static, {priv_dir, sim_web, "www/sim/js", [{mimetypes, cow_mimetypes, all}]}},
			{"/sim/css/[...]", cowboy_static, {priv_dir, sim_web, "www/sim/css", [{mimetypes, cow_mimetypes, all}]}},
			{"/sim/img/[...]", cowboy_static, {priv_dir, sim_web, "www/sim/img", [{mimetypes, cow_mimetypes, all}]}},
			{"/sim/audio/[...]", cowboy_static, {priv_dir, sim_web, "www/sim/audio", [{mimetypes, cow_mimetypes, all}]}},
			{"/sim/login", sim_web_handler_log, []},
			{"/sim/register", sim_web_handler_reg, []},
			{"/sim/contacts/:user_name/get_all", sim_web_handler_cont, [get_all]},
			{"/sim/contacts/:user_name/add/:new_contact", sim_web_handler_cont, [add]},
			{"/sim/contacts/:user_name/remove/:contact_name", sim_web_handler_cont, [remove]}
		]}
	]),
	{ok, _} = cowboy:start_clear(http, [{port, 8000}], #{
		env => #{dispatch => Dispatch}
	}),
	sim_web_dets_dao:start(),
	sim_web_sup:start_link().

stop(_State) ->
	ok.

test_setup() ->
	sim_web_dets_dao:save(#user{user_id = "alex", contacts = ["tom", "john", "sam"], state = online}),
	sim_web_dets_dao:save(#user{user_id = "tom", contacts = ["alex"], state = offline}),
	sim_web_dets_dao:save(#user{user_id = "sam", contacts = ["alex", "john"], state = offline}),
	sim_web_dets_dao:save(#user{user_id = "john", contacts = ["tom", "alex"], state = online}),
	List = dets:match_object(user_db, #user{user_id = '_', _ = '_'}),
	[io:format("~p~n", [U]) || U <- List].

%% ====================================================================
%% Internal functions
%% ====================================================================

