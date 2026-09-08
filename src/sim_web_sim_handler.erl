-module(sim_web_sim_handler).
-moduledoc """
Exposes the following operation IDs:

- `POST` to `/users/:userName/contacts`, OperationId: `addUserContact`:
Add the contact to user&#39;s contacts list.
Add the contact to user&#39;s contacts list

- `DELETE` to `/users/:userName/contacts`, OperationId: `deleteUserContact`:
Remove the contact from user&#39;s contacts list.
Remove the contact from user&#39;s contacts list

- `GET` to `/checksession`, OperationId: `getSession`:
Get web session status.
Returns a session object

- `GET` to `/users/:userName/contacts`, OperationId: `getUserContacts`:
Get user&#39;s contacts with connection status.
Returns a user&#39;s contacts with connection status

- `GET` to `/users`, OperationId: `loginUser`:
User is trying to log in to server.


- `POST` to `/users`, OperationId: `registerUser`:
Register a new user.
Register (or add) a new user with name and password

""".

-behaviour(cowboy_rest).

-include_lib("kernel/include/logger.hrl").

%% Cowboy REST callbacks
-export([init/2]).
-export([allowed_methods/2]).
-export([content_types_accepted/2]).
-export([content_types_provided/2]).
-export([delete_resource/2]).
-export([is_authorized/2]).
-export([valid_content_headers/2]).
-export([resource_exists/2, allow_missing_post/2]).
-export([handle_type_accepted/2, handle_type_provided/2]).

-ignore_xref([handle_type_accepted/2, handle_type_provided/2]).

-export_type([class/0, operation_id/0]).

-type class() :: 'sim'.

-type operation_id() ::
    'addUserContact' %% Add the contact to user&#39;s contacts list
    | 'deleteUserContact' %% Remove the contact from user&#39;s contacts list
    | 'getSession' %% Get web session status
    | 'getUserContacts' %% Get user&#39;s contacts with connection status
    | 'loginUser' %% User is trying to log in to server
    | 'registerUser'. %% Register a new user


-record(state,
        {operation_id :: operation_id(),
         accept_callback :: sim_web_logic_handler:accept_callback(),
         provide_callback :: sim_web_logic_handler:provide_callback(),
         api_key_callback :: sim_web_logic_handler:api_key_callback(),
         context = #{} :: sim_web_logic_handler:context()}).

-type state() :: #state{}.

-spec init(cowboy_req:req(), sim_web_router:init_opts()) ->
    {cowboy_rest, cowboy_req:req(), state()}.
init(Req, {Operations, Module}) ->
	Method = cowboy_req:method(Req),
	OperationID = maps:get(Method, Operations, undefined),
	Storage =
	case application:get_env(sim_web, storage, dets) of
		mysql -> sim_mysql_dao;
		dets -> sim_dets_dao;
		mnesia -> sim_mnesia_dao
	end,
	lager:info([{endtype, server}], "Attempt to process operation ~p~n", 
		[#{
				what => "Attempt to process operation",
				method => Method,
				operation_id => OperationID}]),
	State = #state{
		operation_id = OperationID,
		accept_callback = fun Module:accept_callback/4,
		provide_callback = fun Module:provide_callback/4,
		api_key_callback = fun Module:api_key_callback/2,
		context = #{storage => Storage}
	},
	{cowboy_rest, Req, State}.

-spec allowed_methods(cowboy_req:req(), state()) ->
    {[binary()], cowboy_req:req(), state()}.
allowed_methods(Req, #state{operation_id = 'addUserContact'} = State) ->
    {[<<"POST">>], Req, State};
allowed_methods(Req, #state{operation_id = 'deleteUserContact'} = State) ->
    {[<<"DELETE">>], Req, State};
allowed_methods(Req, #state{operation_id = 'getSession'} = State) ->
    {[<<"GET">>], Req, State};
allowed_methods(Req, #state{operation_id = 'getUserContacts'} = State) ->
    {[<<"GET">>], Req, State};
allowed_methods(Req, #state{operation_id = 'loginUser'} = State) ->
    {[<<"GET">>], Req, State};
allowed_methods(Req, #state{operation_id = 'registerUser'} = State) ->
    {[<<"POST">>], Req, State};
allowed_methods(Req, State) ->
    {[], Req, State}.

-spec is_authorized(cowboy_req:req(), state()) ->
    {true | {false, iodata()}, cowboy_req:req(), state()}.
is_authorized(Req0,
              #state{operation_id = OperationID,
                     api_key_callback = Handler} = State) when
		OperationID == 'addUserContact'; 
		OperationID == 'deleteUserContact'; 
		OperationID == 'getSession'; 
		OperationID == 'getUserContacts'; 
		OperationID == 'loginUser'; 
		OperationID == 'registerUser' ->
    case sim_web_auth:authorize_api_key(Handler, OperationID, header, <<"authorization">>, Req0) of
        {true, Context0, Req} ->
            Context1 = maps:merge(Context0, State#state.context),
            {true, Req, State#state{context = Context1}};
        {false, AuthHeader, Req} ->
            {{false, AuthHeader}, Req, State}
    end;
is_authorized(Req, State) ->
    {true, Req, State}.

-spec allow_missing_post(Req, State) -> 
    {boolean(), Req, State}.
allow_missing_post(Req, State) ->
    {false, Req, State}.

-spec resource_exists(cowboy_req:req(), state()) ->
    {boolean(), cowboy_req:req(), state()}.
resource_exists(Req, State) ->
    sim_web_logic_handler:resource_exist(State#state.operation_id, Req, State).

-spec content_types_accepted(cowboy_req:req(), state()) ->
    {[{binary(), atom()}], cowboy_req:req(), state()}.
content_types_accepted(Req, #state{operation_id = 'addUserContact'} = State) ->
    {[
      {<<"application/json">>, handle_type_accepted}
     ], Req, State};
content_types_accepted(Req, #state{operation_id = 'deleteUserContact'} = State) ->
    {[
      {<<"application/json">>, handle_type_accepted}
     ], Req, State};
content_types_accepted(Req, #state{operation_id = 'getSession'} = State) ->
    {[], Req, State};
content_types_accepted(Req, #state{operation_id = 'getUserContacts'} = State) ->
    {[], Req, State};
content_types_accepted(Req, #state{operation_id = 'loginUser'} = State) ->
    {[], Req, State};
content_types_accepted(Req, #state{operation_id = 'registerUser'} = State) ->
    {[
      {<<"application/json">>, handle_type_accepted}
     ], Req, State};
content_types_accepted(Req, State) ->
    {[], Req, State}.

-spec valid_content_headers(cowboy_req:req(), state()) ->
    {boolean(), cowboy_req:req(), state()}.
valid_content_headers(Req, #state{operation_id = 'addUserContact'} = State) ->
    {true, Req, State};
valid_content_headers(Req, #state{operation_id = 'deleteUserContact'} = State) ->
    {true, Req, State};
valid_content_headers(Req, #state{operation_id = 'getSession'} = State) ->
    {true, Req, State};
valid_content_headers(Req, #state{operation_id = 'getUserContacts'} = State) ->
    {true, Req, State};
valid_content_headers(Req, #state{operation_id = 'loginUser'} = State) ->
    {true, Req, State};
valid_content_headers(Req, #state{operation_id = 'registerUser'} = State) ->
    {true, Req, State};
valid_content_headers(Req, State) ->
    {false, Req, State}.

-spec content_types_provided(cowboy_req:req(), state()) ->
    {[{binary(), atom()}], cowboy_req:req(), state()}.
content_types_provided(Req, #state{operation_id = 'addUserContact'} = State) ->
    {[
      {<<"application/json">>, handle_type_provided}
     ], Req, State};
content_types_provided(Req, #state{operation_id = 'deleteUserContact'} = State) ->
    {[
      {<<"application/json">>, handle_type_provided}
     ], Req, State};
content_types_provided(Req, #state{operation_id = 'getSession'} = State) ->
    {[
      {<<"application/json">>, handle_type_provided}
     ], Req, State};
content_types_provided(Req, #state{operation_id = 'getUserContacts'} = State) ->
    {[
      {<<"application/json">>, handle_type_provided}
     ], Req, State};
content_types_provided(Req, #state{operation_id = 'loginUser'} = State) ->
    {[
      {<<"application/json">>, handle_type_provided}
     ], Req, State};
content_types_provided(Req, #state{operation_id = 'registerUser'} = State) ->
    {[
      {<<"application/json">>, handle_type_provided}
     ], Req, State};
content_types_provided(Req, State) ->
    {[], Req, State}.

-spec delete_resource(cowboy_req:req(), state()) ->
    {boolean(), cowboy_req:req(), state()}.
delete_resource(Req, State) ->
    {Res, Req1, State1} = handle_type_accepted(Req, State),
    {true =:= Res, Req1, State1}.

-spec handle_type_accepted(cowboy_req:req(), state()) ->
    { sim_web_logic_handler:accept_callback_return(), cowboy_req:req(), state()}.
handle_type_accepted(Req, #state{operation_id = OperationID,
                                 accept_callback = Handler,
                                 context = Context} = State) ->
    {Res, Req1, Context1} = Handler(sim, OperationID, Req, Context),
    {Res, Req1, State#state{context = Context1}}.

-spec handle_type_provided(cowboy_req:req(), state()) ->
    { sim_web_logic_handler:provide_callback_return(), cowboy_req:req(), state()}.
handle_type_provided(Req, #state{operation_id = OperationID,
                                 provide_callback = Handler,
                                 context = Context} = State) ->
    {Res, Req1, Context1} = Handler(sim, OperationID, Req, Context),
    {Res, Req1, State#state{context = Context1}}.
