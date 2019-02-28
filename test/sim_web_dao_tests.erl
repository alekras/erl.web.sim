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

%% @hidden
%% @since 2016-09-08
%% @copyright 2015-2017 Alexei Krasnopolski
%% @author Alexei Krasnopolski <krasnop@bellsouth.net> [http://krasnopolski.org/]
%% @version {@version}
%% @doc This module is running unit tests for some modules.

-module(sim_web_dao_tests).

%%
%% Include files
%%
-include_lib("eunit/include/eunit.hrl").
-include_lib("stdlib/include/assert.hrl").
-include_lib("sim_web.hrl").
-include("test.hrl").

%%
%% Import modules
%%
%-import(helper_common, []).

%%
%% Exported Functions
%%
-export([
]).

%%
%% API Functions
%%

sim_web_dao_test_() ->
	[{ setup,
			fun do_start/0,
			fun do_stop/1,
		{ foreachx,
			fun setup/1,
			fun cleanup/2,
			[
				{dets, fun clean_up/2},
				{mysql, fun clean_up/2},
				{dets, fun save/2},
				{mysql, fun save/2},
				{dets, fun get/2},
				{mysql, fun get/2},
				{dets, fun remove/2},
				{mysql, fun remove/2},
				{dets, fun add_contact/2},
				{mysql, fun add_contact/2},
				{dets, fun remove_contact/2},
				{mysql, fun remove_contact/2},
				{dets, fun get_all/2},
				{mysql, fun get_all/2},
				{dets, fun exist/2},
				{mysql, fun exist/2}
			]
		}
	 }
	].

do_start() ->
	application:set_env(lager, error_logger_redirect, false, [{persistent, true}]),
	Handlers = [
    {lager_console_backend, [
      debug, 
      {lager_default_formatter, [
        time, " [",severity,"] ", pid, " ", 
        {module, [module, ":"], [""]}, 
        {function, [function, ":"], [""]}, 
        {line, [line], [""]},
        {endtype, [" -", endtype, "- "], [" - "]}, 
        message, "\n"
      ]}
    ]},
    {lager_file_backend, [{file, "common.log.txt"}, {level, info}]}
  ],

	application:set_env(lager, handlers, Handlers, [{persistent, true}]),
	lager:start(),
	sim_web_mysql_dao:start(),
	sim_web_mysql_dao:cleanup(),

	sim_web_dets_dao:start(),
	sim_web_dets_dao:cleanup().

do_stop(_X) ->
	sim_web_mysql_dao:cleanup(),
	sim_web_mysql_dao:close(),

	sim_web_dets_dao:cleanup(),	
	sim_web_dets_dao:close().	

setup(dets) ->
	sim_web_dets_dao;
setup(mysql) ->
	sim_web_mysql_dao.

cleanup(_, _) ->
	ok.

clean_up(X, Storage) -> {"cleanup [" ++ atom_to_list(X) ++ "]", timeout, 1, fun() ->
	Storage:save(#user{user_id = "alex", contacts = ["bob", "bill"], state = online}),
	Storage:save(#user{user_id = "john", contacts = ["alex", "billy"], state = offline}),

	R = Storage:get_all(),
	?debug_Fmt("::test:: after save user ~p", [R]),	
	?assertEqual(2, length(R)),

	Storage:cleanup(),
	R1 = Storage:get_all(),
	?debug_Fmt("::test:: after cleanup ~p", [R1]),	
	?assertEqual(0, length(R1)),
	?passed
end}.

save(X, Storage) -> {"save [" ++ atom_to_list(X) ++ "]", timeout, 1, fun() ->
	Storage:save(#user{user_id = "alex", contacts = ["bob", "bill"], state = online}),
	Storage:save(#user{user_id = "john", contacts = ["alex", "billy"], state = offline}),

	R = Storage:get_all(),
	?debug_Fmt("::test:: after save user ~p", [R]),	
	?assertEqual(2, length(R)),
	
	Storage:save(#user{user_id = "alex", contacts = ["andrew", "bill"], state = offline}),
	R1 = Storage:get("alex"),
	?debug_Fmt("::test:: R1= ~p", [R1]),	
	?assertMatch(R1, #user{user_id = "alex", contacts = ["andrew", "bill"], state = offline}),
	
	Storage:cleanup(),
	?passed
end}.

get(X, Storage) -> {"get [" ++ atom_to_list(X) ++ "]", timeout, 1, fun() ->
	Storage:save(#user{user_id = "alex", contacts = ["bob", "bill"], state = online}),
	Storage:save(#user{user_id = "john", contacts = ["alex", "billy"], state = offline}),
	Storage:save(#user{user_id = "william", state = offline}),

	R = Storage:get("alex"),
	?assertMatch(#user{user_id = "alex", contacts = _, state = online}, R),
	?assert(lists:all(fun(E) -> lists:member(E, R#user.contacts) end, ["bob", "bill"])),
	
	R1 = Storage:get("alexei"),
	?assertMatch(R1, undefined),

	R2 = Storage:get("john"),
	?assertMatch(#user{user_id = "john", contacts = _, state = offline}, R2),
	?assert(lists:all(fun(E) -> lists:member(E, R2#user.contacts) end, ["alex", "billy"])),

	R3 = Storage:get("william"),
	?assertMatch(#user{user_id = "william", contacts = [], state = offline}, R3),

	Storage:cleanup(),
	?passed
end}.

remove(X, Storage) -> {"remove [" ++ atom_to_list(X) ++ "]", timeout, 1, fun() ->
	Storage:save(#user{user_id = "alex", contacts = ["bob", "bill"], state = online}),
	Storage:save(#user{user_id = "john", contacts = ["alex", "billy"], state = offline}),

	R = Storage:get_all(),
	?debug_Fmt("::test:: after save user ~p", [R]),	
	?assertEqual(2, length(R)),
	
	Storage:remove("john"),
	R1 = Storage:get_all(),
	?debug_Fmt("::test:: after remove user ~p", [R1]),	
	?assertEqual(1, length(R1)),
	[R2] = R1,
	?assertMatch(#user{user_id = "alex", contacts = _, state = online}, R2),
	?assert(lists:all(fun(E) -> lists:member(E, R2#user.contacts) end, ["bob","bill"])),
	
	Storage:cleanup(),
	?passed
end}.

add_contact(X, Storage) -> {"add contact [" ++ atom_to_list(X) ++ "]", timeout, 1, fun() ->
	Storage:save(#user{user_id = "alex", contacts = ["bob", "bill"], state = online}),

	R = Storage:get_all(),
	?debug_Fmt("::test:: after save user ~p", [R]),	
	?assertEqual(1, length(R)),

	Storage:add_contact("alex", "andrew"),
	R1 = Storage:get("alex"),
	?debug_Fmt("::test:: after add contact ~p", [R1]),	
	?assertMatch(R1, #user{user_id = "alex", contacts = ["andrew","bob","bill"], state = online}),

	Storage:cleanup(),
	?passed
end}.

remove_contact(X, Storage) -> {"remove contact [" ++ atom_to_list(X) ++ "]", timeout, 1, fun() ->
	Storage:save(#user{user_id = "alex", contacts = ["andrew", "bob", "bill"], state = online}),

	R = Storage:get_all(),
	?debug_Fmt("::test:: after save user ~p", [R]),	
	?assertEqual(1, length(R)),

	Storage:remove_contact("alex", "bob"),
	R1 = Storage:get("alex"),
	?debug_Fmt("::test:: after remove contact ~p", [R1]),	
	?assertMatch(R1, #user{user_id = "alex", contacts = ["andrew","bill"], state = online}),

	Storage:cleanup(),
	?passed
end}.

get_all(X, Storage) -> {"get all [" ++ atom_to_list(X) ++ "]", timeout, 1, fun() ->
	Storage:save(#user{user_id = "alex", contacts = ["bob", "bill"], state = online}),
	Storage:save(#user{user_id = "john", contacts = ["alex", "billy"], state = offline}),
	Storage:save(#user{user_id = "william", contacts = ["alex", "john"], state = offline}),

	R = Storage:get_all(),
	?debug_Fmt("::test:: after save user ~p", [R]),	
	?assertEqual(3, length(R)),
	[_, R1, _] = R,
	?assertMatch(#user{user_id = "john", contacts = _, state = offline}, R1),
	?assert(lists:all(fun(E) -> lists:member(E, R1#user.contacts) end, ["alex", "billy"])),

	Storage:cleanup(),
	?passed
end}.

exist(X, Storage) -> {"exist [" ++ atom_to_list(X) ++ "]", timeout, 1, fun() ->
	Storage:save(#user{user_id = "alex", contacts = ["bob", "bill"], state = online}),
	Storage:save(#user{user_id = "john", contacts = ["alex", "billy"], state = offline}),

	R = Storage:exist("alex"),
	?assertMatch(R, true),
	R1 = Storage:exist("alexei"),
	?assertMatch(R1, false),
	R2 = Storage:exist("john"),
	?assertMatch(R2, true),

	Storage:cleanup(),
	?passed
end}.


%% read(X, Storage) -> {"read [" ++ atom_to_list(X) ++ "]", timeout, 1, fun() ->
%% 	R = Storage:get(client, #primary_key{client_id = "lemon", packet_id = 101}),
%% %	?debug_Fmt("::test:: read returns R ~120p", [R]),	
%%  	?assertEqual(#publish{topic = "AK",payload = <<"Payload lemon 1">>}, R#storage_publish.document),
%% 	Ra = Storage:get(client, #primary_key{client_id = "plum", packet_id = 101}),
%% %	?debug_Fmt("::test:: read returns Ra ~120p", [Ra]),	
%%  	?assertEqual(undefined, Ra),
%%  	R1 = Storage:get(client, #subs_primary_key{topic = "AKtest", client_id = "lemon"}),
%% %	?debug_Fmt("::test:: read returns R1 ~120p", [R1]),	
%%  	?assertEqual(#storage_subscription{key = #subs_primary_key{topic = "AKtest", client_id = "lemon"}, qos = 0, callback = {erlang, timestamp}}, R1),
%%  	R1a = Storage:get(client, #subs_primary_key{topic = "AK_Test", client_id = "lemon"}),
%% %	?debug_Fmt("::test:: read returns R1a ~120p", [R1a]),	
%%  	?assertEqual(undefined, R1a),
%%  	R2 = Storage:get(client, {client_id, "apple"}),
%% %	?debug_Fmt("::test:: read returns R2 ~120p", [R2]),	
%%  	?assertEqual(list_to_pid("<0.4.3>"), R2),
%%  	R2a = Storage:get(client, {client_id, "plum"}),
%% %	?debug_Fmt("::test:: read returns R2a ~120p", [R2a]),	
%%  	?assertEqual(undefined, R2a),
%% 	?passed
%% end}.
%% 
%% extract_topic(X, Storage) -> {"extract topic [" ++ atom_to_list(X) ++ "]", timeout, 1, fun() ->
%% 	R = Storage:get_client_topics(client, "orange"),
%% %	?debug_Fmt("::test:: read returns ~120p", [R]),	
%% 	?assert(lists:member({"+/December",0,{size}}, R)),
%% 	?assert(lists:member({"/+/December/+",2,{length}}, R)),
%% 	?assert(lists:member({"Winter/+",1,{mqtt_client_test, callback}}, R)),
%% 	?passed
%% end}.
%% 	
%% extract_matched_topic(X, Storage) -> {"extract matched topic [" ++ atom_to_list(X) ++ "]", timeout, 1, fun() ->
%% 	R = Storage:get_matched_topics(client, #subs_primary_key{topic = "Winter/December", client_id = "orange"}),
%% %	?debug_Fmt("::test:: read returns ~120p", [R]),	
%% 	?assertEqual([{"+/December",0,{size}},
%% 								{"Winter/+",1,{mqtt_client_test, callback}}], R),
%% 
%% 	R1 = Storage:get_matched_topics(client, "Winter/December"),
%% %	?debug_Fmt("::test:: read returns ~120p", [R1]),	
%% 	?assertEqual([{storage_subscription,{subs_primary_key,"+/December","apple"},2,{length}},
%% 								{storage_subscription,{subs_primary_key,"+/December","orange"},0,{size}},
%% 								{storage_subscription,{subs_primary_key,"Winter/#","pear"},1,{length}},
%% 								{storage_subscription,{subs_primary_key,"Winter/+","orange"},1,{mqtt_client_test, callback}}], R1),
%% 	?passed
%% end}.
%% 
%% read_all(X, Storage) -> {"read all [" ++ atom_to_list(X) ++ "]", timeout, 1, fun() ->
%% 	R = Storage:get_all(client, {session, "lemon"}),
%% %	?debug_Fmt("::test:: read returns ~120p", [R]),	
%% 	?assertEqual(3, length(R)),
%% 	?passed
%% end}.
%% 	
%% update(X, Storage) -> {"update [" ++ atom_to_list(X) ++ "]", timeout, 1, fun() ->
%% 	Storage:save(client, #storage_publish{key = #primary_key{client_id = "lemon", packet_id = 101}, document = #publish{topic = "", payload = <<>>}}),
%% 	R = Storage:get(client, #primary_key{client_id = "lemon", packet_id = 101}),
%% %	?debug_Fmt("::test:: read returns ~120p", [R]),
%% 	?assertEqual(#publish{topic = "",payload = <<>>}, R#storage_publish.document),
%% 	Storage:save(client, #storage_publish{key = #primary_key{client_id = "lemon", packet_id = 201}, document = undefined}),
%% 	R1 = Storage:get(client, #primary_key{client_id = "lemon", packet_id = 201}),
%% %	?debug_Fmt("::test:: read returns ~120p", [R1]),
%% 	?assertEqual(undefined, R1#storage_publish.document),
%% 	Storage:save(client, #storage_subscription{key = #subs_primary_key{topic = "Winter/+", client_id = "orange"}, qos=2, callback = {erlang, binary_to_list}}),
%% 	R2 = Storage:get(client, #subs_primary_key{topic = "Winter/+", client_id = "orange"}),
%% %	?debug_Fmt("::test:: read returns ~120p", [R1]),
%% 	?assertEqual(2, R2#storage_subscription.qos),
%% 	?assertEqual({erlang, binary_to_list}, R2#storage_subscription.callback),
%% 	?passed
%% end}.
%% 	
%% delete(X, Storage) -> {"delete [" ++ atom_to_list(X) ++ "]", timeout, 1, fun() ->
%% 	Storage:remove(client, #primary_key{client_id = "lemon", packet_id = 101}),
%% 	R = Storage:get(client, #primary_key{client_id = "lemon", packet_id = 101}),
%% %	?debug_Fmt("::test:: after delete ~p", [R]),	
%% 	?assertEqual(undefined, R),
%% 	
%% 	Storage:remove(client, #subs_primary_key{topic = "Winter/+", client_id = "orange"}),
%% 	R1 = Storage:get(client, #subs_primary_key{topic = "Winter/+", client_id = "orange"}),
%% %	?debug_Fmt("::test:: after delete ~p", [R1]),	
%% 	?assertEqual(undefined, R1),
%% 	R2 = Storage:get_all(client, topic),	
%% %	?debug_Fmt("::test:: read returns ~120p", [R2]),	
%% 	?assertEqual(7, length(R2)),
%% 	
%% 	Storage:remove(client, #subs_primary_key{client_id = "apple", _='_'}),
%% 	R3 = Storage:get(client, #subs_primary_key{topic = "+/December", client_id = "apple"}),
%% %	?debug_Fmt("::test:: after delete ~p", [R3]),	
%% 	?assertEqual(undefined, R3),
%% 	R4 = Storage:get_all(client, topic),	
%% %	?debug_Fmt("::test:: read returns ~120p", [R4]),	
%% 	?assertEqual(5, length(R4)),
%% 	
%% 
%% 	?passed
%% end}.
