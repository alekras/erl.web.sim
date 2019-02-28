%% @author alexei
%% @doc @todo Add description to sim_web_handler.


-module(sim_web_handler_log).
-include("sim_web.hrl").

%% ====================================================================
%% API functions
%% ====================================================================
-export([init/2]).

init(Req0, Opts) ->
	Method = cowboy_req:method(Req0),
	HasBody = cowboy_req:has_body(Req0),

	Req = login(Method, HasBody, Req0),
	{ok, Req, Opts}.

%% ====================================================================
%% Internal functions
%% ====================================================================

login(<<"POST">>, true, Req) ->
	{ok, PostVals, Req1} = cowboy_req:read_urlencoded_body(Req),
	User = proplists:get_value(<<"user">>, PostVals),
	Password = proplists:get_value(<<"password">>, PostVals),
	if (User =:= undefined) or (Password =:= undefined) ->
			cowboy_req:reply(400, #{}, <<"Wrong body.">>, Req1);
		true ->
			make_reply(binary:bin_to_list(User), Password, Req1)
	end;
login(<<"POST">>, false, Req) ->
	cowboy_req:reply(400, #{}, <<"Missing body.">>, Req);
login(_, _, Req) ->
	%% Method not allowed.
	cowboy_req:reply(405, Req).

make_reply(User, Password, Req) ->
	ReqTo0 = {?URL ++ "/rest/user/" ++ User, [{"X-Forwarded-For", "localhost"}, {"Accept", "application/json"}]},
	Response0 = httpc:request(get, ReqTo0, [], []),
	{ok, {{_Pr, Status, _}, _Headers, Body}} = Response0,
	case Status of
		200 ->
			Enc_Password = crypto:hash(md5, Password),
			Body1 = re:replace(Body, "\r|\n", "", [global, {return, binary}]),
			if Enc_Password =:= Body1 ->
					cowboy_req:reply(200, #{
						<<"content-type">> => <<"application/json">>
					}, <<"{\"status\":\"ok\"}">>, Req);
				 true ->
					cowboy_req:reply(200, #{
						<<"content-type">> => <<"application/json">>
					}, <<"{\"status\":\"fail\"}">>, Req)
			end;
		_ ->
			cowboy_req:reply(200, #{
				<<"content-type">> => <<"application/json">>
			}, <<"{\"status\":\"fail\"}">>, Req)
	end.
