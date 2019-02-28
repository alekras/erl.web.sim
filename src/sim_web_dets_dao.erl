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


-module(sim_web_dets_dao).
%%
%% Include files
%%
-include("sim_web.hrl").

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

start() ->
	DB_Folder = application:get_env(sim_web, dets_home_folder, "priv/dets-storage"),
	case dets:open_file(user_db, [{file, filename:join(DB_Folder, "user_db.bin")}, {type, set}, {auto_save, 10000}, {keypos, #user.user_id}]) of
		{ok, user_db} ->
			true;
		{error, Reason1} ->
			lager:error("Cannot open ~p dets: ~p~n", [user_db, Reason1]),
			false
	end.

save(#user{user_id = Key} = Document) ->
	case dets:insert(user_db, Document) of
		{error, Reason} ->
			lager:error("user_db: Insert failed: ~p; reason ~p~n", [Key, Reason]),
			false;
		ok ->
			true
	end.

add_contact(User_Id, Contact_Id) ->
	case ?MODULE:get(User_Id) of
		undefined -> false;
		#user{contacts = Contacts} = User ->
			save(User#user{contacts = [Contact_Id | Contacts]})
	end.

remove(User_Id) ->
	case dets:match_delete(user_db, #user{user_id = User_Id, _ = '_'}) of
		{error, Reason} ->
			lager:error("Delete is failed for key: ~p with error code: ~p~n", [User_Id, Reason]),
			false;
		ok -> true
	end.

remove_contact(User_Id, Contact_Id) ->
	case ?MODULE:get(User_Id) of
		undefined -> false;
		#user{contacts = Contacts} = User ->
			save(User#user{contacts = lists:delete(Contact_Id, Contacts)})
	end.

get(User_Id) ->
	case dets:match_object(user_db, #user{user_id = User_Id, _ = '_'}) of
		{error, Reason} ->
			lager:error("Get failed: user_id=~p reason=~p~n", [User_Id, Reason]),
			undefined;
		[User] -> User;
		_ ->
			undefined
	end.

get_all() ->
	case dets:match_object(user_db, #user{user_id = '_', _ = '_'}) of 
		{error, Reason} -> 
			lager:error("match_object failed: ~p~n", [Reason]),
			[];
		R -> R
	end.

cleanup() ->
	dets:delete_all_objects(user_db).

exist(User_Id) ->
	case dets:member(user_db, User_Id) of
		{error, Reason} ->
			lager:error("Exist failed: key=~p reason=~p~n", [User_Id, Reason]),
			false;
		R -> R
	end.

close() -> 
	dets:close(user_db).
%% ====================================================================
%% Internal functions
%% ====================================================================
