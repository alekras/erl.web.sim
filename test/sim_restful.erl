%%
%% Copyright (C) 2015-2022 by krasnop@bellsouth.net (Alexei Krasnopolski)
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

%% @hidden
%% @since 2022-06-15
%% @copyright 2015-2022 Alexei Krasnopolski
%% @author Alexei Krasnopolski <krasnop@bellsouth.net> [http://krasnopolski.org/]
%% @version {@version}
%% @doc This module implements a testing of MQTT restful service.

-module(sim_restful).

%%
%% Include files
%%
%% -include_lib("eunit/include/eunit.hrl").
-include_lib("stdlib/include/assert.hrl").
-include("sim_web.hrl").
-include("test.hrl").

-export([
	get_login/0,
	get_session_a/0,
	get_session_b/0,
	post_register/0,
	post_add_contact/0,
	delete_contact/0,
	get_all_contacts/0,
	delete_mqtt_user/1
]).

-import(testing, [wait_all/1]).
%%
%% API Functions
%%

post_register() ->
	post_register("Alexei"),
	post_register("Sam").

%% curl -X 'POST' 'http://localhost:8000/sim/users' \
%%  -H 'accept: application/json' \
%%  -H 'authorization: sim-web' \
%%  -H 'Content-Type: application/json' \
%%  -d '{"userName": "alex","password": "aaaaaaa"}'

%% {"success": true,"userName":"alex3","contacts": ["echo"]}
%% {"code": 400,"message": "Already exists."}

post_register(User) ->
	Req0 = {
		?TEST_REST_SERVER_URL ++ "/sim/users",
		headers(),
		"application/json",
		"{\"userName\":\"" ++ User ++ "\",\"password\":\"aaaaaaa\"}"
	},
	Response0 = httpc:request(post, Req0, [{timeout, 1000}], []),
	{ok, {{_Pr, Status, _}, _Headers, Body}} = Response0,
	?debug_Fmt(" **REGISTER** Status: ~p Body from SIM: ~p~n", [Status, Body]),
	?assertEqual(200, Status),
	Body_map = json:decode(list_to_binary(Body)),
	?assertMatch(#{<<"success">> := true,<<"userName">> := _,<<"contacts">> := [<<"echo">>]}, Body_map),

	Response1 = httpc:request(post, Req0, [{timeout, 1000}], []),
	{ok, {{_Pr1, Status1, _}, _Headers1, Body1}} = Response1,
	?debug_Fmt(" **REGISTER** Status1: ~p Body1 from SIM: ~p~n", [Status1, Body1]),
	?assertEqual(400, Status1),
	Body_map1 = json:decode(list_to_binary(Body1)),
	?assertMatch(#{<<"code">> := 400,<<"message">> := <<"Already exists.">>}, Body_map1),

	?PASSED.

%% curl -X 'GET' \
%%  'http://localhost:8000/sim/users?userName=alex&password=alex' \
%%  -H 'accept: application/json' \
%%  -H 'authorization: sim-web'

%% {"success": true,"userName": "alex","contacts": {"echo": "on"}}

get_login() ->
	Req0 = {
		?TEST_REST_SERVER_URL ++ "/sim/users?userName=Alexei&password=aaaaaaa",
		headers()
	},
	Response0 = httpc:request(get, Req0, [{timeout, 1000}], []),
	{ok, {{_Pr, Status, _}, _Headers, Body}} = Response0,
	?debug_Fmt(" **LOGIN** Status: ~p Body: ~p~n", [Status, Body]),
	Cookie = proplists:get_value("set-cookie", _Headers, "no"),
	?debug_Fmt(" >>> Cookies after Response #0: ~p~n", [Cookie]),	
	?assertEqual(200, Status),
	Body_map = json:decode(list_to_binary(Body)),
	?assertMatch(#{<<"success">> := true, <<"userName">> := <<"Alexei">>, <<"contacts">> := #{<<"echo">> := <<"on">>}}, Body_map),

	Req1 = {
		?TEST_REST_SERVER_URL ++ "/sim/users?userName=AlexeiK&password=aaaaaaa",
		headers()
	},
	Response1 = httpc:request(get, Req1, [{timeout, 1000}], []),
	{ok, {{_Pr1, Status1, _}, _Headers1, Body1}} = Response1,
	?debug_Fmt(" **LOGIN** Status: ~p Body: ~p~n", [Status1, Body1]),
	?assertEqual(404, Status1),
	Body_map1 = json:decode(list_to_binary(Body1)),
	?assertMatch(#{<<"code">> := 404,<<"message">> := <<"User does not found">>}, Body_map1),

	?PASSED.

%% curl -X 'POST' 'http://localhost:8000/sim/users/alex/contacts' \
%%  -H 'accept: application/json' \
%%  -H 'authorization: sim-web' \
%%  -H 'Content-Type: application/json' \
%%  -d '{"contactName": "admin"}'

%% {"Sam": "off","echo": "on"}
%% {"code":"code","message":"message"}

post_add_contact() ->
	Req0 = {
		?TEST_REST_SERVER_URL ++ "/sim/users/Alexei/contacts",
		headers(),
		"application/json",
		"{\"contactName\": \"Sam\"}"
	},
	Response0 = httpc:request(post, Req0, [{timeout, 1000}], []),
	{ok, {{_Pr, Status, _}, _Headers, Body}} = Response0,
	?debug_Fmt(" **ADD CONTACT** Status: ~p Body: ~p~n", [Status, Body]),
	?assertEqual(200, Status),
	Body_map = json:decode(list_to_binary(Body)),
	?assertMatch(#{<<"echo">> := <<"on">>,<<"Sam">> := <<"off">>}, Body_map),

	?PASSED.

%% curl -X 'GET' 'http://localhost:8000/sim/users/alex/contacts'
%%  -H 'accept: application/json' 
%%  -H 'authorization: sim-web'

%% {"Sam": "off","echo": "on"}

get_all_contacts() ->
	Req0 = {
		?TEST_REST_SERVER_URL ++ "/sim/users/Alexei/contacts",
		headers()
	},
	Response0 = httpc:request(get, Req0, [], []),
	{ok, {{_Pr, Status, _}, _Headers, Body}} = Response0,
	?debug_Fmt(" **GET ALL CONTACTS** Status: ~p Body from SIM: ~p~n", [Status, Body]),
	?assertEqual(200, Status),
	Body_map = json:decode(list_to_binary(Body)),
	?assertMatch(#{<<"echo">> := <<"on">>,<<"Sam">> := <<"off">>}, Body_map),

	?PASSED.

%% curl -X 'DELETE' 'http://localhost:8000/sim/users/Alexei/contacts'
%%  -H 'accept: application/json'
%%  -H 'authorization: sim-web' 
%%  -H 'Content-Type: application/json'
%%  -d '{"contactName": "Sam"}'

%% {"echo": "on"}

delete_contact() ->
	Req0 = {
		?TEST_REST_SERVER_URL ++ "/sim/users/Alexei/contacts",
		headers(),
		"application/json",
		"{\"contactName\":\"Sam\"}"
	},
	Response0 = httpc:request(delete, Req0, [], []),
	{ok, {{_Pr, Status, _}, _Headers, Body}} = Response0,
	?debug_Fmt(" **REMOVE CONTACT** Status: ~p Body from SIM: ~p~n", [Status, Body]),
	?assertEqual(200, Status),
	Body_map = json:decode(list_to_binary(Body)),
	?assertMatch(#{<<"echo">> := <<"on">>}, Body_map),

	Response1 = httpc:request(delete, Req0, [], []),
	{ok, {{_Pr1, Status1, _}, _Headers1, Body1}} = Response1,
	?debug_Fmt(" **REMOVE CONTACT** Status: ~p Body from SIM: ~p~n", [Status1, Body1]),
	?assertEqual(200, Status1),
	Body_map1 = json:decode(list_to_binary(Body1)),
	?assertMatch(#{<<"echo">> := <<"on">>}, Body_map1),

	?PASSED.

%% curl -X 'GET' 'http://localhost:8000/sim/checksession'
%%  -H 'accept: application/json'
%%  -H 'authorization: sim-web'

%% {"userName":"userName","password":"password"}

get_session_b() ->
	get_session(#{}).

get_session_a() ->
	get_session(#{<<"userName">> => <<"Alexei">>,<<"password">> => <<"aaaaaaa">>}).

get_session(Ptn) ->
	Req0 = {
		?TEST_REST_SERVER_URL ++ "/sim/checksession",
		headers()
	},
	Response0 = httpc:request(get, Req0, [], []),
	{ok, {{_Pr, Status, _}, _Headers, Body}} = Response0,
	?debug_Fmt(" **GET SESSION** Status: ~p Body from SIM: ~p~n", [Status, Body]),
	?assertEqual(200, Status),
	Body_map = json:decode(list_to_binary(Body)),
	?assertMatch(Ptn, Body_map),
	?PASSED.

%% curl -X 'DELETE' 'http://localhost:8080/rest/user/alex' \
%%  -H 'accept: */*' \
%%  -H 'authorization: mqtt'

delete_mqtt_user(User) ->
	Host = application:get_env(sim_web, mqtt_rest_url, "http://localhost:18080"),
	ReqTo0 = {
		Host ++ "/rest/user/" ++ User, 
		[
		 {"X-Forwarded-For", "localhost"},
		 {"Accept", "application/json"},
		 {"authorization", "mqtt"}
		]
	},
	Response0 = httpc:request(delete, ReqTo0, [], []),
	{ok, {{_Pr, Status, _}, _Headers, Body}} = Response0,
	?debug_Fmt("**DELETE** User: ~p. Response body from MQTT: ~p, status:~p~n", [User, Body, Status]).

headers() ->
[
 {"authorization", "sim-web"},
 {"Accept", "application/json"}
].
