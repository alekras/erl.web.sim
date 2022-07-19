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
	Host = application:get_env(sim_web, mqtt_rest_url, "http://localhost:18080"),
	ReqTo0 = {
		Host ++ "/rest/user/" ++ User, 
		[
		 {"X-Forwarded-For", "localhost"},
		 {"Accept", "application/json"},
		 {"X-API-Key", "mqtt-rest-api"}
		]
	},
	Response0 = httpc:request(get, ReqTo0, [], []),
	{ok, {{_Pr, Status, _}, _Headers, Body}} = Response0,
	case Status of
		200 ->
			lager:info("Body from MQTT: ~p~n", [Body]),
			Enc_Password = list_to_binary(binary_to_hex(crypto:hash(md5, Password))),
			Json_Body = jsx:decode(binary:list_to_bin(Body), [return_maps]),
			Password_From_DB = maps:get(<<"password">>, Json_Body, <<"">>),
			lager:info("Passwords: ~p/~p~n", [Enc_Password, Password_From_DB]),
			if Enc_Password =:= Password_From_DB ->
%% Check User in local sim-web database. If not create new one.
					L =
					case sim_web_dets_dao:get(User) of
						#user{user_id = User, contacts = Contacts} ->
							Contacts;
						_ ->
							sim_web_dets_dao:save(#user{user_id = User, contacts = []}),
							[]
					end,

					cowboy_req:reply(200, #{
						<<"content-type">> => <<"application/json">>
					}, sim_web_handler_cont:contacts_json(L), Req);
				true ->
					cowboy_req:reply(200, #{
						<<"content-type">> => <<"application/json">>
					}, <<"{\"status\":\"fail\"}">>, Req)
			end;
		_ ->
			cowboy_req:reply(400, #{
				<<"content-type">> => <<"application/json">>
			}, <<"{\"status\":\"bad request\"}">>, Req)
	end.

binary_to_hex(Binary) -> [conv(N) || <<N:4>> <= Binary].

conv(N) when N < 10 -> N + 48; 
conv(N) -> N + 87. 
