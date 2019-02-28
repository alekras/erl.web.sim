%% @author alexei
%% @doc @todo Add description to sim_web_handler.

-module(sim_web_handler_reg).
-include("sim_web.hrl").

%% ====================================================================
%% API functions
%% ====================================================================
-export([init/2]).

init(Req0, Opts) ->
	Method = cowboy_req:method(Req0),
	HasBody = cowboy_req:has_body(Req0),

	Req = register(Method, HasBody, Req0),
	{ok, Req, Opts}.
%% ====================================================================
%% Internal functions
%% ====================================================================

register(<<"POST">>, true, Req) ->
	{ok, Props, Req1} = cowboy_req:read_urlencoded_body(Req),
	User = proplists:get_value(<<"user">>, Props),
	Password1 = proplists:get_value(<<"password1">>, Props),
	Password2 = proplists:get_value(<<"password2">>, Props),
	if (User =:= undefined) or (Password1 =:= undefined) or (Password2 =:= undefined)->
			cowboy_req:reply(400, #{}, <<"Wrong body.">>, Req1);
		true ->
			make_reply(binary:bin_to_list(User), Password1, Password2, Req1)
	end;
register(<<"POST">>, false, Req) ->
	cowboy_req:reply(400, #{}, <<"Missing body.">>, Req);
register(_, _, Req) ->
	%% Method not allowed.
	cowboy_req:reply(405, Req).

make_reply(User, Password1, Password2, Req1) ->
	if (Password1 =:= Password2) and (length(Password1) > 3) ->
			ReqTo0 = {?URL ++ "/rest/user/" ++ User, [{"X-Forwarded-For", "localhost"}, {"Accept", "application/json"}]},
			Response0 = httpc:request(get, ReqTo0, [], []),
			{ok, {{_Pr, Status, _}, _Headers, _Body}} = Response0,
			case Status of
				200 ->
					cowboy_req:reply(200, #{
						<<"content-type">> => <<"application/json">>
					}, <<"{\"status\":\"fail\", \"reason\":\"exist\"}">>, Req1);
				404 ->
					ReqTo1 = {?URL ++ "/rest/user/" ++ User ++ "/pswd/" ++ binary:bin_to_list(Password1), [{"X-Forwarded-For", "localhost"}], "application/json", []},
					Response1 = httpc:request(post, ReqTo1, [{ssl, [{verify, 0}]}], []),
					io:format(user, "Response #1: ~p~n", [Response1]),
					cowboy_req:reply(200, #{
						<<"content-type">> => <<"application/json">>
					}, <<"{\"status\":\"ok\"}">>, Req1)
			end;
		true ->
			cowboy_req:reply(200, #{
				<<"content-type">> => <<"application/json">>
			}, <<"{\"status\":\"fail\", \"reason\":\"password\"}">>, Req1)
	end.
