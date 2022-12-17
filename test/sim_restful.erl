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
	post_login/0,
	post_register/0,
	post_add_contact/0,
	post_remove_contact/0,
	get_all_contacts/0,
	delete_mqtt_user/1
]).

-import(testing, [wait_all/1]).
%%
%% API Functions
%%

post_login() ->
	Req0 = {
		?TEST_REST_SERVER_URL ++ "/sim/login",
		headers(),
		"application/json",
		"user=Alexei&password=aaaaaaa"
	},
	Response0 = httpc:request(post, Req0, [{timeout, 1000}], []),
	{ok, {{_Pr, Status, _}, _Headers, Body}} = Response0,
	?debug_Fmt(" **LOGIN** Status: ~p Body: ~p~n", [Status, Body]),
	?assertEqual(200, Status),
	?assertEqual("{\"status\":\"ok\",\"contacts\":{}}", Body),

	?PASSED.

post_register() ->
	post_register("Alexei"),
	post_register("Sam").

post_register(User) ->
	Req0 = {
		?TEST_REST_SERVER_URL ++ "/sim/register",
		headers(),
		"application/json",
		"user=" ++ User ++ "&password1=aaaaaaa&password2=aaaaaaa"
	},
	Response0 = httpc:request(post, Req0, [{timeout, 1000}], []),
	{ok, {{_Pr, Status, _}, _Headers, Body}} = Response0,
	?debug_Fmt(" **REGISTER** Status: ~p Body from SIM: ~p~n", [Status, Body]),
	?assertEqual(200, Status),
	?assertEqual("{\"status\":\"ok\"}", Body),

	?PASSED.

post_add_contact() ->
	Req0 = {
		?TEST_REST_SERVER_URL ++ "/sim/contacts/Alexei/add/Sam",
		headers(),
		"application/json",
		[]
	},
	Response0 = httpc:request(post, Req0, [{timeout, 1000}], []),
	{ok, {{_Pr, Status, _}, _Headers, Body}} = Response0,
	?debug_Fmt(" **ADD CONTACT** Status: ~p Body: ~p~n", [Status, Body]),
	?assertEqual(200, Status),
	?assertEqual("{\"status\":\"ok\",\"contacts\":{\"Sam\":{\"status\":\"off\"}}}", Body),

	?PASSED.

get_all_contacts() ->
	Req0 = {
		?TEST_REST_SERVER_URL ++ "/sim/contacts/Alexei/get_all",
		headers()
	},
	Response0 = httpc:request(get, Req0, [], []),
	{ok, {{_Pr, Status, _}, _Headers, Body}} = Response0,
	?debug_Fmt(" **GET ALL CONTACTS** Status: ~p Body from SIM: ~p~n", [Status, Body]),
	?assertEqual(200, Status),
	?assertEqual("{\"status\":\"ok\",\"contacts\":{\"Sam\":{\"status\":\"off\"}}}", Body),

	?PASSED.

post_remove_contact() ->
	Req0 = {
		?TEST_REST_SERVER_URL ++ "/sim/contacts/Alexei/remove/Sam",
		headers(),
		"application/json",
		[]
	},
	Response0 = httpc:request(post, Req0, [], []),
	{ok, {{_Pr, Status, _}, _Headers, Body}} = Response0,
	?debug_Fmt(" **REMOVE CONTACT** Status: ~p Body from SIM: ~p~n", [Status, Body]),
	?assertEqual(200, Status),
	?assertEqual("{\"status\":\"ok\",\"contacts\":{}}", Body),

	Response1 = httpc:request(post, Req0, [], []),
	{ok, {{_Pr1, Status1, _}, _Headers1, Body1}} = Response1,
	?debug_Fmt(" **REMOVE CONTACT** Status: ~p Body from SIM: ~p~n", [Status, Body]),
	?assertEqual(200, Status1),
	?assertEqual("{\"status\":\"ok\",\"contacts\":{}}", Body1),

	?PASSED.

delete_mqtt_user(User) ->
	Host = application:get_env(sim_web, mqtt_rest_url, "http://localhost:18080"),
	ReqTo0 = {
		Host ++ "/rest/user/" ++ User, 
		[
		 {"X-Forwarded-For", "localhost"},
		 {"Accept", "application/json"},
		 {"X-API-Key", "mqtt-rest-api"}
		]
	},
	Response0 = httpc:request(delete, ReqTo0, [], []),
	{ok, {{_Pr, Status, _}, _Headers, Body}} = Response0,
	?debug_Fmt("**DELETE** User: ~p. Response body from MQTT: ~p, status:~p~n", [User, Body, Status]).

headers() ->
[
 {"X-Forwarded-For", "localhost"},
 {"Accept", "application/json"}
].
