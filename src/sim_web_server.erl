-module(sim_web_server).
-moduledoc """
This is a RESTful API of SIM server. The API manages SIM user's records. See for details https://github.com/alekras/erl.web.sim
""".

-define(DEFAULT_LOGIC_HANDLER, sim_web_logic_handler).

-export([start/2]).
-ignore_xref([start/2]).

-spec start(term(), #{transport      => tcp | ssl,
                      transport_opts => ranch:opts(),
                      protocol_opts  => cowboy:opts(),
                      logic_handler  => module()}) ->
    {ok, pid()} | {error, any()}.
start(ID, Params) ->
    Transport = maps:get(transport, Params, tcp),
    TransportOpts = maps:get(transport_opts, Params, #{}),
    ProtocolOpts = maps:get(procotol_opts, Params, #{}),
    LogicHandler = maps:get(logic_handler, Params, ?DEFAULT_LOGIC_HANDLER),
    CowboyOpts = get_cowboy_config(LogicHandler, ProtocolOpts),
    case Transport of
        ssl ->
            cowboy:start_tls(ID, TransportOpts, CowboyOpts);
        tcp ->
            cowboy:start_clear(ID, TransportOpts, CowboyOpts)
    end.

get_cowboy_config(LogicHandler, ExtraOpts) ->
    DefaultOpts = get_default_opts(LogicHandler),
    maps:fold(fun get_cowboy_config/3, DefaultOpts, ExtraOpts).

get_cowboy_config(env, #{dispatch := _Dispatch} = Env, AccIn) ->
    AccIn#{env => Env};
get_cowboy_config(env, NewEnv, #{env := OldEnv} = AccIn) ->
    Env = maps:merge(OldEnv, NewEnv),
    AccIn#{env => Env};
get_cowboy_config(Key, Value, AccIn) ->
    AccIn#{Key => Value}.

get_default_dispatch(LogicHandler) ->
    Paths = sim_web_router:get_paths(LogicHandler),
    #{dispatch => cowboy_router:compile(Paths)}.

get_default_opts(LogicHandler) ->
    #{env => get_default_dispatch(LogicHandler)}.
