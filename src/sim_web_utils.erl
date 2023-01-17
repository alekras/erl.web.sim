%% @author alexei
%% @doc @todo Add description to sim_web_utils.


-module(sim_web_utils).
-include("sim_web.hrl").

%% ====================================================================
%% API functions
%% ====================================================================
-export([
	get_session/1
]).

get_session(Req0) ->
	Cookies = cowboy_req:parse_cookies(Req0),
	lager:debug("<<GET Session>> retrieve Cookies: ~p~n", [Cookies]),
	case lists:keyfind(<<"sessionid">>, 1, Cookies) of
		{_, SessionId} ->
			case ets:match_object(sessionTable, #session{id = SessionId, _ = '_'}) of
				[SessionObj] ->
					SessionObj;
				_E -> 
					undefined
			end;
		false -> undefined
	end.

%% ====================================================================
%% Internal functions
%% ====================================================================


