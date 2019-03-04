%% @author alexei
%% @doc @todo Add description to set_db_4test.


-module(set_db_4test).

-export([set_db/0]).
-include("../include/sim_web.hrl").
%% ====================================================================
%% API functions
%% ====================================================================

init() ->
	R = dets:open_file(user_db, 
								[{file, filename:join("../priv/dets-storage", "user_db.bin")}, 
								 {type, set}, 
								 {auto_save, 10000}, 
								 {keypos, #user.user_id}]),
	io:format("Dets returns ~p~n", [R]).
	
set_db() ->
	init(),
	ok = dets:insert(user_db, [
		#user{user_id = "alex", contacts = ["tom", "jonh", "sam"], state = online},
		#user{user_id = "tom", contacts = ["alex"], state = offline},
		#user{user_id = "sam", contacts = ["alex", "jonh"], state = offline},
		#user{user_id = "jonh", contacts = ["tom", "alex"], state = online}
		]),
	List = dets:match_object(user_db, #user{user_id = '_', _ = '_'}),
	[io:format("~p~n", [U]) || U <- List].

%% ====================================================================
%% Internal functions
%% ====================================================================


