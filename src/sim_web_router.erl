-module(sim_web_router).

-export([get_paths/1]).

-type method() :: binary().
-type operations() :: #{method() => sim_web_api:operation_id()}.
-type init_opts()  :: {operations(), module()}.

-export_type([init_opts/0]).

-spec get_paths(LogicHandler :: module()) -> cowboy_router:routes().
get_paths(LogicHandler) ->
    PreparedPaths = maps:fold(
                      fun(Path, #{operations := Operations, handler := Handler}, Acc) ->
                              [{Path, Handler, Operations} | Acc]
                      end, [], group_paths()
                     ),
		[{'_', 
			lists:append(
				[
					{"/sim", cowboy_static, {priv_file, sim_web, "www/index-react.html"}},
					{"/sim/js/[...]", cowboy_static, {priv_dir, sim_web, "www/js", [{mimetypes, cow_mimetypes, all}]}},
					{"/sim/css/[...]", cowboy_static, {priv_dir, sim_web, "www/css", [{mimetypes, cow_mimetypes, all}]}},
					{"/sim/img/[...]", cowboy_static, {priv_dir, sim_web, "www/img", [{mimetypes, cow_mimetypes, all}]}},
					{"/sim/audio/[...]", cowboy_static, {priv_dir, sim_web, "www/audio", [{mimetypes, cow_mimetypes, all}]}},

					{"/sim/v3/swagger-ui", cowboy_static, {priv_file, sim_web, "dist/index.html"}},
					{"/sim/v3/swagger-spec", cowboy_static, {priv_file, sim_web, "openapi.json"}},
					{"/sim/v3/[...]", cowboy_static, {priv_dir, sim_web, "dist", [{mimetypes, cow_mimetypes, all}]}}
				],
				[{P, H, {O, LogicHandler}} || {P, H, O} <- PreparedPaths]
			)
		}].

group_paths() ->
    maps:fold(
      fun(OperationID, #{servers := Servers, base_path := BasePath, path := Path,
                         method := Method, handler := Handler}, Acc) ->
              FullPaths = build_full_paths(Servers, BasePath, Path),
              merge_paths(FullPaths, OperationID, Method, Handler, Acc)
      end, #{}, get_operations()).

build_full_paths([], BasePath, Path) ->
    [lists:append([BasePath, Path])];
build_full_paths(Servers, _BasePath, Path) ->
    [lists:append([Server, Path]) || Server <- Servers ].

merge_paths(FullPaths, OperationID, Method, Handler, Acc) ->
    lists:foldl(
      fun(Path, Acc0) ->
              case maps:find(Path, Acc0) of
                  {ok, PathInfo0 = #{operations := Operations0}} ->
                      Operations = Operations0#{Method => OperationID},
                      PathInfo = PathInfo0#{operations => Operations},
                      Acc0#{Path => PathInfo};
                  error ->
                      Operations = #{Method => OperationID},
                      PathInfo = #{handler => Handler, operations => Operations},
                      Acc0#{Path => PathInfo}
              end
      end, Acc, FullPaths).

get_operations() ->
    #{ 
       'addUserContact' => #{
            servers => [],
            base_path => "/sim",
            path => "/users/:userName/contacts",
            method => <<"POST">>,
            handler => 'sim_web_sim_handler'
        },
       'deleteUserContact' => #{
            servers => [],
            base_path => "/sim",
            path => "/users/:userName/contacts",
            method => <<"DELETE">>,
            handler => 'sim_web_sim_handler'
        },
       'getSession' => #{
            servers => [],
            base_path => "/sim",
            path => "/checksession",
            method => <<"GET">>,
            handler => 'sim_web_sim_handler'
        },
       'getUserContacts' => #{
            servers => [],
            base_path => "/sim",
            path => "/users/:userName/contacts",
            method => <<"GET">>,
            handler => 'sim_web_sim_handler'
        },
       'loginUser' => #{
            servers => [],
            base_path => "/sim",
            path => "/users",
            method => <<"GET">>,
            handler => 'sim_web_sim_handler'
        },
       'registerUser' => #{
            servers => [],
            base_path => "/sim",
            path => "/users",
            method => <<"POST">>,
            handler => 'sim_web_sim_handler'
        }
    }.
