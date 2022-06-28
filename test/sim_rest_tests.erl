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
%% @since 2022-06-01
%% @copyright 2015-2022 Alexei Krasnopolski
%% @author Alexei Krasnopolski <krasnop@bellsouth.net> [http://krasnopolski.org/]
%% @version {@version}
%% @doc This module is running erlang unit tests.

-module(sim_rest_tests).

%%
%% Include files
%%
-include_lib("eunit/include/eunit.hrl").
-include("sim_web.hrl").
-include("test.hrl").

%%
%% API Functions
%%
sim_server_test_() ->
	[ 
		{ setup, 
			fun sim_rest_test_utils:do_start/0, 
			fun sim_rest_test_utils:do_stop/1, 
			{inorder, [
				{"rest service", timeout, 15, fun sim_restful:post_register/0},
				{"rest service", fun sim_restful:post_login/0},
				{"rest service", fun sim_restful:post_add_contact/0},
				{"rest service", fun sim_restful:get_all_contacts/0},
				{"rest service", fun sim_restful:post_remove_contact/0},
				{foreachx, 
					fun sim_rest_test_utils:do_setup/1,
					fun sim_rest_test_utils:do_cleanup/2,
					[
						{{1, keep_alive}, fun keep_alive/2}
					]
				}
			]}
		}
	].

keep_alive(_, _Conn) -> {"keep alive test", timeout, 15, fun() ->
	?PASSED
end}.
