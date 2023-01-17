%% @author alexei
%% @doc @todo Add description to sim_web_handler.


-module(sim_web_handler_check_session).
-include("sim_web.hrl").

%% ====================================================================
%% API functions
%% ====================================================================
-export([init/2]).

init(Req0, Opts) ->
	Method = cowboy_req:method(Req0),
	Req = check_session(Method, Req0),
	lager:debug(">> check_session, method: ~p~n", [Method]),
	{ok, Req, Opts}.

%% ====================================================================
%% Internal functions
%% ====================================================================

check_session(<<"GET">>, Req0) ->
	case sim_web_utils:get_session(Req0) of
		undefined ->
			cowboy_req:reply(
				200,
				#{<<"content-type">> => <<"application/json">>},
				<<"{\"session\":null}">>,
				Req0);
		#session{userId = User, password = Password} ->
			cowboy_req:reply(
				200,
				#{<<"content-type">> => <<"application/json">>},
				binary:list_to_bin("{\"session\":{\"user\":\"" ++ User ++ "\",\"password\":\"" ++ Password ++ "\"}}"),
				Req0)
	end;
check_session(_, Req) ->
	%% Method not allowed.
	cowboy_req:reply(405, Req).
