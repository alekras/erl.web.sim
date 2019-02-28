%%
%% Copyright (C) 2015-2017 by krasnop@bellsouth.net (Alexei Krasnopolski)
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

%% @since 2016-09-08
%% @copyright 2015-2017 Alexei Krasnopolski
%% @author Alexei Krasnopolski <krasnop@bellsouth.net> [http://krasnopolski.org/]
%% @version {@version}
%% @doc @todo Add description to dets_dao.


-module(sim_web_mysql_dao).
%%
%% Include files
%%
-include("sim_web.hrl").
-include_lib("mysql_client/include/my.hrl").
-include_lib("stdlib/include/ms_transform.hrl").

%% ====================================================================
%% API functions
%% ====================================================================
-export([
	start/0,
	close/0,
	save/1,
	add_contact/2,
	remove/1,
	remove_contact/2,
	get/1,
	get_all/0,
	cleanup/0,
	exist/1
]).

%% db_id(client) ->
%% 	"mqtt_db_cli";
%% db_id(server) ->
%% 	"mqtt_db_srv".
%% 
%% end_type_2_name(client) -> mqtt_client;
%% end_type_2_name(server) -> mqtt_server.

start() ->
	MYSQL_SERVER_HOST_NAME = application:get_env(sim_web, mysql_host, "localhost"),
	MYSQL_SERVER_PORT = application:get_env(sim_web, mysql_port, 3306),
	MYSQL_USER = application:get_env(sim_web, mysql_user, "mqtt_user"),
	MYSQL_PASSWORD = application:get_env(sim_web, mysql_user, "mqtt_password"),
	R = my:start_client(),
	lager:info("Starting MySQL client connection to ~p:~p status: ~p",[MYSQL_SERVER_HOST_NAME, MYSQL_SERVER_PORT, R]),
	DB_name = "sim_web_db",
	DS_def = #datasource{
		name = user_db,
		host = MYSQL_SERVER_HOST_NAME, 
		port = MYSQL_SERVER_PORT,
%		database = DB_name,
		user = MYSQL_USER, 
		password = MYSQL_PASSWORD, 
		flags = #client_options{}
	},
	case my:new_datasource(DS_def) of
		{ok, _Pid} ->
			Connect = datasource:get_connection(user_db),
			R0 = connection:execute_query(Connect, "CREATE DATABASE IF NOT EXISTS " ++ DB_name),
			lager:debug("create DB: ~p", [R0]),
			datasource:return_connection(user_db, Connect);
		#mysql_error{} -> ok
	end,
  datasource:close(user_db),

	case my:new_datasource(DS_def#datasource{database = DB_name}) of
		{ok, Pid} ->
			Conn = datasource:get_connection(user_db),

			Query1 =
				"CREATE TABLE IF NOT EXISTS user ("
				"user_id char(100) DEFAULT '',"
				" state char(15) DEFAULT 'offline',"
				" PRIMARY KEY (user_id)"
				" ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8",
			R1 = connection:execute_query(Conn, Query1),
			lager:debug("create user table: ~p", [R1]),

			Query2 =
				"CREATE TABLE IF NOT EXISTS contact ("
				"contact_id char(100) DEFAULT '',"
				" user_id varchar(100) DEFAULT '',"
				" INDEX user_id_index (user_id),"
				" FOREIGN KEY (user_id) REFERENCES user(user_id) ON DELETE CASCADE"
%				" PRIMARY KEY (contact_id)"
				" ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8",
			R2 = connection:execute_query(Conn, Query2),
			lager:debug("create contact table: ~p", [R2]),

			datasource:return_connection(user_db, Conn),
			Pid;
		#mysql_error{} -> ok
	end.

save(#user{user_id = User_Id, contacts = Contacts, state = State}) ->
	Query = ["REPLACE INTO user VALUES ('",
		User_Id, "','",
		atom_to_list(State), "')"],
	execute_query(Query),
	
%	Query1 = ["DELETE FROM contact WHERE user_id='",User_Id, "'"],
%	execute_query(Query1),
	
	Query2 = "INSERT INTO contact(contact_id,user_id) VALUES " ++
		lists:flatten(lists:join(",", [ ["('", Contact_Id, "','", User_Id, "')"] || Contact_Id <- Contacts])),
	execute_query(Query2).

remove(User_Id) ->
	Query = ["DELETE FROM user WHERE user_id='",User_Id, "'"],
	execute_query(Query).
%% 	Query1 = ["DELETE FROM contact WHERE user_id='",User_Id, "'"],
%% 	execute_query(Query1).

add_contact(User_Id, Contact_Id) ->
	case ?MODULE:get(User_Id) of
		undefined -> false;
		#user{contacts = Contacts} = User ->
			?MODULE:save(User#user{contacts = [Contact_Id | Contacts]})
	end.

remove_contact(User_Id, Contact_Id) ->
	case ?MODULE:get(User_Id) of
		undefined -> false;
		#user{contacts = Contacts} = User ->
			?MODULE:save(User#user{contacts = lists:delete(Contact_Id, Contacts)})
	end.

get(User_Id) ->
	Query = ["SELECT u.user_id, u.state, c.contact_id FROM user AS u LEFT JOIN contact AS c ON u.user_id = c.user_id WHERE u.user_id='",User_Id, "'"], % @todo
	case execute_query(Query) of
		[] -> undefined;
		R1 -> 
			lager:debug("R1=~p", [R1]),
			[User_Id,S,_] = hd(R1),
			#user{user_id = User_Id, contacts = [Contact_Id || [_,_,Contact_Id] <- R1, Contact_Id =/= null], state = list_to_atom(S)}
	end.
	
get_all() ->
	Query = "SELECT user_id FROM user",
	R = execute_query(Query),
	[?MODULE:get(User_Id) || [User_Id] <- R].

cleanup() ->
	Conn = datasource:get_connection(user_db),
	{_, R1} = connection:execute_query(Conn, "DELETE FROM user"),
	lager:debug("user delete: ~p", [R1]),
%% 	{_, R2} = connection:execute_query(Conn, "DELETE FROM contact"),
%% 	lager:debug("contact delete: ~p", [R2]),
	datasource:return_connection(user_db, Conn).

exist(User_Id) ->
	Query = [
		"SELECT user_id FROM user WHERE user_id='", User_Id, "'"],
	case execute_query(Query) of
		[] -> false;
		[_] -> true
	end.

close() -> 
	datasource:close(user_db).
%% ====================================================================
%% Internal functions
%% ====================================================================

execute_query(Query) ->
	Conn = datasource:get_connection(user_db),
	Rez =
	case connection:execute_query(Conn, Query) of
		{_, R} ->
			lager:debug("Query: ~120p response: ~p", [Query, R]),
			R;
		Other ->
			lager:error("Error with Query: ~120p, ~120p", [Query, Other]),
			[]
	end,
	datasource:return_connection(user_db, Conn),
	Rez.
