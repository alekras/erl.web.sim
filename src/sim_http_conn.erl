%%
%% Copyright (C) 2015-2026 by krasnop@bellsouth.net (Alexei Krasnopolski)
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

%% @since 2026-09-01
%% @copyright 2015-2026 Alexei Krasnopolski
%% @author Alexei Krasnopolski <krasnop@bellsouth.net> [http://krasnopolski.org/]
%% @version {@version}
%% @doc @todo Add description to dets_dao.


-module(sim_http_conn).
%%
%% Include files
%%
-include("sim_web.hrl").

%% ====================================================================
%% API functions
%% ====================================================================
-export([
	get_user/1,
	add_user/2,
	get_statuses/1,
	get_status/1
]).

get_user(User_name) when is_binary(User_name) ->
	get_user(binary_to_list(User_name));
get_user(User_name) ->
	Host = application:get_env(sim_web, mqtt_host, "localhost"),
	Port = application:get_env(sim_web, mqtt_port_rest, 8080),
	URL = lists:concat(["http://", Host, ":", Port, "/rest/user/", User_name]),
	ReqTo0 = {
		URL,
		[
		 {"X-Forwarded-For", "localhost"},
		 {"Accept", "application/json"},
		 {"authorization", "mqtt"}
		]
	},
	Response0 = httpc:request(get, ReqTo0, [], []),
	{ok, {{_Pr, Status, _}, _Headers, Body}} = Response0,
	case Status of
		200 ->
			lager:info("Body from MQTT server: ~p~n", [Body]),
			Json_Body = json:decode(binary:list_to_bin(Body)),
			lager:info("JSON Body: ~p~n", [Json_Body]),
			Json_Body;
		_ ->
			undefined
	end.

%% http://localhost:8080/rest/user/{alex}, body = #{password := "aaaaa", roles := []} 
add_user(UserName, Password) when is_binary(UserName) ->
	add_user(binary_to_list(UserName), Password);
add_user(UserName, Password) ->
	Host = application:get_env(sim_web, mqtt_host, "localhost"),
	Port = application:get_env(sim_web, mqtt_port_rest, 8080),
	URL = lists:concat(["http://", Host, ":", Port, "/rest/user/", UserName]),
	ReqTo0 = {
		URL,
		[
		 {"Accept", "application/json"},
		 {"authorization", "mqtt"}
		],
		"application/json",
		iolist_to_binary(json:encode(#{password => Password, roles => [<<"GUEST">>]}))
	},
	Response0 = httpc:request(post, ReqTo0, [], []),
	{ok, {{_Pr, Status, _}, _Headers, Body}} = Response0,
	case Status of
		201 -> true;
		400 -> 
			lager:info("Body from MQTT server: ~p~n", [Body]),
			false;
		_ ->
			lager:info("Body from MQTT server: ~p~n", [Body]),
			false
	end.

%% http://localhost:8080/rest/user/status?users=alex,tom
get_statuses([]) -> #{};
get_statuses(Contacts_list) ->
	Host = application:get_env(sim_web, mqtt_host, "localhost"),
	Port = application:get_env(sim_web, mqtt_port_rest, 8080),
	Users = string:join(Contacts_list, ","),
	Users1 = string:replace(Users, " ", "%20", all),
	URL = lists:concat(["http://", Host, ":", Port, "/rest/user/status?users=", Users1]),
	lager:info("URL encoded: ~p", [URL]),
	ReqTo0 = {URL, 
		[
		 {"Accept", "application/json"},
		 {"authorization", "mqtt"}
		]},
	ConnStatuses =
	case httpc:request(get, ReqTo0, [], []) of
		{ok, {{_Pr, Status, _}, _Headers, Body}} ->
			case Status of
				200 -> 
					lager:debug("Body from MQTT: ~p~n",[Body]),
					json:decode(binary:list_to_bin(Body));
				404 -> []
			end;
		{error, _Reason} ->
			lager:error("Conection error: ~p", [_Reason]),
			[];
		_R -> 
			lager:error("Conection error. Responce: ~p", [_R]),
			[]
	end,
	lager:info("get /rest/user/status?users=~p Connection statuses: ~p", [Users, ConnStatuses]),
%% Convert from [#{id => UserName, status := Status}, ...] to #{UserName<0> := Status, ...}
	maps:from_list([ {Id, Status} || #{<<"id">> := Id, <<"status">> := Status} <- ConnStatuses]).

get_status(User) when is_binary(User) ->
	get_status(binary_to_list(User));
get_status(User) ->
	Host = application:get_env(sim_web, mqtt_host, "localhost"),
	Port = application:get_env(sim_web, mqtt_port_rest, 8080),
	URL = lists:concat(["http://", Host, ":", Port, "/rest/user/", User, "/status"]),
	lager:info("URL: ~p", [URL]),
	ReqTo0 = {URL, 
		[
		 {"Accept", "application/json"},
		 {"authorization", "mqtt"}
		]},
%% Body = {"id": "alex","status": "off"}
	case httpc:request(get, ReqTo0, [], []) of
		{ok, {{_Pr, Status, _}, _Headers, Body}} ->
			case Status of
				200 -> 
					lager:debug("Body from MQTT: ~p~n",[Body]),
					#{<<"status">> := ConnStatus} = json:decode(list_to_binary(Body)),
					ConnStatus;
				400 -> not_found;
				404 -> not_found
			end;
		{error, _Reason} ->
			lager:error("Conection error: ~p", [_Reason]),
			not_found;
		_R -> 
			lager:error("Conection error. Responce: ~p", [_R]),
			not_found
	end.


