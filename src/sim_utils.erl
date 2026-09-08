%% @author alexei
%% @doc @todo Add description to sim_web_utils.


-module(sim_utils).
-include("sim_web.hrl").

%% ====================================================================
%% API functions
%% ====================================================================
-export([
	process_session/3,
	get_session/1,
	get_contacts/2
]).

process_session(Req0, User, Password) ->
	case sim_utils:get_session(Req0) of
		undefined ->
			SessionId = base64:encode(crypto:strong_rand_bytes(32)),
			lager:debug("<<Session>> start session with id: ~p~n", [SessionId]),
			ets:match_delete(sessionTable, #session{userId = User, _ = '_'}),
			ets:insert(sessionTable, 
				#session{
					id = SessionId,
					created = os:system_time(second),
					userId = User,
					password = Password
				}
			),
			cowboy_req:set_resp_cookie(<<"sessionid">>, SessionId, Req0, #{max_age => 21600, path => "/sim"}); %% 6*60*60 @TODO from ENV
		#session{} -> Req0
	end.

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

get_contacts(User, #{storage := Storage}) ->
	case Storage:get(User) of
		#user{user_id = _User, contacts = Contacts} ->
			L = sim_http_conn:get_statuses(Contacts),
			lager:info("~n --- Contacts: ~p~n --- Json: ~p~n", [Contacts, L]),
			L;
		_ ->
			#{}
	end.


%% ====================================================================
%% Internal functions
%% ====================================================================


