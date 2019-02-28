%% @author alexei
%% @doc @todo Add description to im.


-module(im).

%% ====================================================================
%% API functions
%% ====================================================================
-export([
	login/3,
	register/3
]).

-define(URL, "http://localhost:8880").

login(SessionID, Env, Input) ->
%	io:format(user, "^^^^^^^^^ HTTPD login: ~p~n~p~n", [Env, Input]),
	Props = httpd:parse_query(Input),
	io:format(user, "^^^^^^^^^ HTTPD properties: ~p~n", [Props]),
	User = proplists:get_value("user", Props),
	Password = proplists:get_value("password", Props),
	io:format(user, "^^^^^^^^^ user: ~p   password: ~p~n", [User, Password]),

	case proplists:get_value(request_method, Env) of
		"GET" -> 
		  mod_esi:deliver(SessionID, [
				"Status: 405 Method Not Allowed\r\n\r\n"
  			]);
		"POST" -> 
			Host = proplists:get_value(http_host, Env),
			Req0 = {?URL ++ "/rest/user/" ++ User, [{"X-Forwarded-For", "localhost"}, {"Accept", "application/json"}]},
			Response0 = httpc:request(get, Req0, [], []),
			io:format("Response #0: ~p~n", [Response0]),
			{ok, {{_Pr, Status, _}, _Headers, Body}} = Response0,
			case Status of
				200 ->
					Enc_Password = crypto:hash(md5, list_to_binary(Password)),
					Body1 = re:replace(Body, "\r|\n", "", [global, {return, binary}]),
					io:format(user, "Body: ~p  enc password: ~p~n", [Body1, Enc_Password]),
					if Enc_Password =:= Body1 ->
								mod_esi:deliver(SessionID, [
%									"Location: https://" ++ Host ++ "/chat.html?user=" ++ User ++ "&password=" ++ Password ++ "\r\n",
%									"Status: 303 See Other\r\n",
									"Content-Type: application/json\r\n\r\n", 
									"{\"status\":\"ok\"}"
								]);
						 true ->
								mod_esi:deliver(SessionID, [
%									"Location: https://" ++ Host ++ "/login_error.html\r\n",
%									"Status: 303 See Other\r\n",
									"Content-Type: application/json\r\n\r\n", 
									"{\"status\":\"fail\"}"
								])
					end;
				_ ->
					mod_esi:deliver(SessionID, [
%						"Location: https://" ++ Host ++ "/login_error.html\r\n",
%						"Status: 303 See Other\r\n",
						"Content-Type: application/json\r\n\r\n", 
						"{\"status\":\"fail\"}"
					])
			end
	end.

register(SessionID, Env, Input) ->
%  io:format(user, "^^^^^^^^^ HTTPD register: ~p~n~p~n", [Env, Input]),
  Props = httpd:parse_query(Input),
  io:format(user, "^^^^^^^^^ HTTPD properties: ~p~n", [Props]),
	User = proplists:get_value("user", Props),
	Password1 = proplists:get_value("password1", Props),
	Password2 = proplists:get_value("password2", Props),
	io:format(user, "^^^^^^^^^ user: ~p   password1: ~p   password2: ~p~n", [User, Password1, Password2]),
	case proplists:get_value(request_method, Env) of
		"GET" -> 
		  mod_esi:deliver(SessionID, [
				"Status: 405 Method Not Allowed\r\n\r\n"
  			]);
		"POST" -> 
			if (Password1 =:= Password2) and (length(Password1) > 3) ->
					Req0 = {?URL ++ "/rest/user/" ++ User, [{"X-Forwarded-For", "localhost"}, {"Accept", "application/json"}]},
					Response0 = httpc:request(get, Req0, [], []),
					io:format("Response #0: ~p~n", [Response0]),
					{ok, {{_Pr, Status, _}, _Headers, _Body}} = Response0,
					case Status of
						200 ->
							mod_esi:deliver(SessionID, [
								"Content-Type: application/json\r\n\r\n", 
								"{\"status\":\"fail\", \"reason\":\"exist\"}"
							]);
						404 ->
							Req1 = {?URL ++ "/rest/user/" ++ User ++ "/pswd/" ++ Password1, [{"X-Forwarded-For", "localhost"}], "application/json", []},
							Response1 = httpc:request(post, Req1, [{ssl, [{verify, 0}]}], []),
							io:format(user, "Response #1: ~p~n", [Response1]),
							mod_esi:deliver(SessionID, [
								"Content-Type: application/json\r\n\r\n", 
								"{\"status\":\"ok\"}"
							])
					end;	
				true ->
					mod_esi:deliver(SessionID, [
								"Content-Type: application/json\r\n\r\n", 
								"{\"status\":\"fail\", \"reason\":\"password\"}"
					])
			end
	end.


%% ====================================================================
%% Internal functions
%% ====================================================================


