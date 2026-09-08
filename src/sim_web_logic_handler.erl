-module(sim_web_logic_handler).

-include("sim_web.hrl").

-type accept_callback_return() ::
        stop
        | boolean()
        | {true, iodata()}
        | {created, iodata()}
        | {see_other, iodata()}.
-type provide_callback_return() ::
        stop
        | cowboy_req:resp_body().
-type api_key_callback() ::
    fun((sim_web_api:operation_id(), binary()) -> {true, context()} | {false, iodata()}).
-type accept_callback() ::
    fun((sim_web_api:class(), sim_web_api:operation_id(), cowboy_req:req(), context()) ->
            {accept_callback_return(), cowboy_req:req(), context()}).
-type provide_callback() ::
    fun((sim_web_api:class(), sim_web_api:operation_id(), cowboy_req:req(), context()) ->
            {cowboy_req:resp_body(), cowboy_req:req(), context()}).
-type context() :: #{_ := _}.

-export_type([context/0, api_key_callback/0,
              accept_callback_return/0, provide_callback_return/0,
              accept_callback/0, provide_callback/0]).

-optional_callbacks([api_key_callback/2]).

-callback api_key_callback(sim_web_api:operation_id(), binary()) ->
    {true, context()} | {false, iodata()}.

-callback accept_callback(sim_web_api:class(), sim_web_api:operation_id(), cowboy_req:req(), context()) ->
    {accept_callback_return(), cowboy_req:req(), context()}.

-callback provide_callback(sim_web_api:class(), sim_web_api:operation_id(), cowboy_req:req(), context()) ->
    {provide_callback_return(), cowboy_req:req(), context()}.

-export([api_key_callback/2, accept_callback/4, provide_callback/4, resource_exist/3]).
-ignore_xref([api_key_callback/2, accept_callback/4, provide_callback/4]).

-record(state,
        {operation_id,
         accept_callback :: accept_callback(),
         provide_callback :: provide_callback(),
         api_key_callback :: api_key_callback(),
         context = #{} :: context()}).

-spec api_key_callback(sim_web_api:operation_id(), binary()) -> {true, #{}}.
api_key_callback(OperationID, ApiKey) ->
    lager:info([{endtype, server}], "api_key_callback Operation: ~p ApiKey: ~p~n", [OperationID, ApiKey]),
    case ApiKey of
        <<"sim-web">> -> {true, #{}};
        _ -> {false, <<>>}
    end.

resource_exist(OperationID, Req0, #state{context = Context0} = State) when 
		OperationID == 'addUserContact'; 
		OperationID == 'deleteUserContact'; 
		OperationID == 'getUserContacts'; 
		OperationID == 'loginUser' ->
	ValidatorState = sim_web_api:prepare_validator(),
	case sim_web_api:populate_request(OperationID, Req0, ValidatorState) of
		{ok, Model, Req1} ->
			Context1 = maps:merge(Context0, Model),
			#{userName := User} = Context1,
			case find_user(User) of
				undefined ->
					Context2 = Context1#{user_record => undefined},
					Binary_resp = json:encode(#{code => 404, message => <<"User does not found">>}),
					Req2 = cowboy_req:set_resp_body(Binary_resp, Req1),
					{false, Req2, State#state{context = Context2}};
				#{} = User_rec ->
					Context2 = Context1#{user_record => User_rec},
					if (OperationID == 'addUserContact') ->
							#{'Contact' := #{<<"contactName">> := CN}} = Context2,
							ContactName = binary_to_list(CN),
							case find_user(ContactName) of
								undefined ->
									Binary_resp = json:encode(#{code => 404, message => <<"User's contact does not found">>}),
									Req2 = cowboy_req:set_resp_body(Binary_resp, Req1),
									{false, Req2, State#state{context = Context2}};
								_ ->
									Context3 = Context2#{contactName => ContactName},
									Context4 = maps:remove('Contact', Context3),
									{true, Req1, State#state{context = Context4}}
							end;
						true ->
							{true, Req1, State#state{context = Context2}}
					end
			end;
		{error, _Reason, Req1} ->
			lager:debug([{endtype, server}], "Error: ~p~n", [_Reason]),
			Binary_resp = json:encode(#{code => 400, message => <<"Invalid request">>}),
			Req2 = cowboy_req:set_resp_body(Binary_resp, Req1),
			{false, Req2, Context0}
	end;
resource_exist(_OperationID, Req, State) ->
	{true, Req, State}.

find_user(User) ->
	case sim_http_conn:get_user(User) of
		undefined ->
			lager:debug([{endtype, server}], "USER DOES NOT EXIST: ~p~n", [User]),
			undefined;
		User_record ->
			lager:debug([{endtype, server}], "USER EXISTS User: ~p User record: ~p~n", [User, User_record]),
			User_record
	end.

%% registerUser, addUserContact, deleteUserContact
-spec accept_callback(sim_web_api:class(), sim_web_api:operation_id(), cowboy_req:req(), context()) ->
    {accept_callback_return(), cowboy_req:req(), context()}.
accept_callback(_Class, 'registerUser' = OperationID, Req0, Context0) ->
	ValidatorState = sim_web_api:prepare_validator(),
	case sim_web_api:populate_request(OperationID, Req0, ValidatorState) of
		{ok, Model, Req1} ->
			Context1 = maps:merge(Context0, Model),
%% 'UserReq' => #{<<"password">> => <<"aaaaaaa">>,<<"userName">> => <<"alex">>}
			#{storage := Storage, 'UserReq' := #{<<"password">> := Password,<<"userName">> := User}} = Context1,
			{R, Response} =
			case find_user(User) of
				undefined ->
					case sim_http_conn:add_user(User, Password) of
						true ->
							true = Storage:save(#user{user_id = User, contacts = ["echo"]}),
							{true, #{success => true, userName => User, contacts => [<<"echo">>]}};
						false ->
							{true, #{success => false, userName => User, contacts => []}}
					end;
				#{} ->
					{false, #{code => 400, message => <<"Already exists.">>}}
			end,
			Binary_resp = json:encode(Response),
			Req2 = cowboy_req:set_resp_body(Binary_resp, Req1),
			{R, Req2, Context1};
		{error, _Reason, Req1} ->
			Binary_resp = json:encode(#{code => 400, message => <<"Invalid request">>}),
			Req2 = cowboy_req:set_resp_body(Binary_resp, Req1),
			{false, Req2, Context0}
	end;
accept_callback(_Class, 'addUserContact', Req0, Context0) ->
%% userName => <<"alex">>,contactName => "admin"}}
	#{storage := Storage, userName := UserName, contactName := ContactName} = Context0,
	case Storage:get(UserName) of
		undefined ->
			New_contacts_list = ["echo", ContactName];
		#user{contacts = Contacts_list} ->
			New_contacts_list = 
			case lists:member(ContactName, Contacts_list) of
				true -> Contacts_list;
				false ->  [ContactName | Contacts_list]
			end
	end,
	true = Storage:save(#user{user_id = binary_to_list(UserName), contacts = New_contacts_list}),
	Binary_resp = json:encode(sim_http_conn:get_statuses(New_contacts_list)),
	Req2 = cowboy_req:set_resp_body(Binary_resp, Req0),
	{true, Req2, Context0};
accept_callback(_Class, 'deleteUserContact', Req0, Context0) ->
%% userName => <<"alex">>,contactName => "admin"}}
	#{storage := Storage, userName := UserName, 'Contact' := #{<<"contactName">> := CN}} = Context0,
	ContactName = binary_to_list(CN),
	case Storage:get(UserName) of
		undefined ->
			New_contacts_list = ["echo"];
		#user{contacts = Contacts_list} ->
			New_contacts_list = lists:delete(ContactName, Contacts_list) 
	end,
	true = Storage:save(#user{user_id = binary_to_list(UserName), contacts = New_contacts_list}),
	Binary_resp = json:encode(sim_http_conn:get_statuses(New_contacts_list)),
	Req2 = cowboy_req:set_resp_body(Binary_resp, Req0),
	{true, Req2, Context0};
accept_callback(Class, OperationID, Req, Context) ->
	lager:info([{endtype, server}], "accept_callback::~n  class: ~p~n  OperationId: ~p~n  Request: ~p~n  Context: ~p~n",
		[Class, OperationID, Req, Context]),
	{true, Req, Context}.

%% loginUser, getUserContacts
-spec provide_callback(sim_web_api:class(), sim_web_api:operation_id(), cowboy_req:req(), context()) ->
    {cowboy_req:resp_body(), cowboy_req:req(), context()}.
provide_callback(_Class, OperationID, Req0, Context0) when 
		OperationID == 'getUserContacts';
		OperationID == 'getSession';
		OperationID == 'loginUser' ->
	process_provide_callback(OperationID, Req0, Context0);

provide_callback(Class, OperationID, Req, Context) ->
	lager:info([{endtype, server}], "provide_callback::~n  class: ~p~n  OperationId: ~p~n  Request: ~p~n  Context: ~p~n",
		[Class, OperationID, Req, Context]),
	{<<"{}">>, Req, Context}.

process_provide_callback('loginUser', Req, Context) ->
	#{user_record := #{<<"password">> := Db_password}, userName := User, password := Plain_password} = Context,
	Enc_Password = list_to_binary(binary_to_hex(crypto:hash(md5, Plain_password))),
	Response_map =
	if Enc_Password =:= Db_password ->
		lager:info([{endtype, server}], "Login success for ~p~n", [User]),
		Req1 = sim_utils:process_session(Req, User, Plain_password),
		Contacts = sim_utils:get_contacts(User, Context),
		lager:info([{endtype, server}], "User's contacts ~p~n", [Contacts]),
		#{success => true, userName => User, contacts => Contacts};
	true ->
		lager:info("Login failed~n", []),
		Req1 = Req,
		#{success => false, userName => User, contacts => #{}}
	end,
	
	Binary_resp = json:encode(Response_map),
	{Binary_resp, Req1, Context};
process_provide_callback('getUserContacts', Req, Context) ->
	#{userName := User} = Context,
	Contacts = sim_utils:get_contacts(User, Context),
	lager:info([{endtype, server}], "User's contacts ~p~n", [Contacts]),
	
	Binary_resp = json:encode(Contacts),
	{Binary_resp, Req, Context};
process_provide_callback('getSession', Req, Context) ->
	case sim_utils:get_session(Req) of
		undefined ->
			SessionResp = #{};
		#session{userId = User, password = Password} ->
			SessionResp = #{userName => User, password => Password}
	end,
	Binary_resp = json:encode(SessionResp),
	{Binary_resp, Req, Context}.

binary_to_hex(Binary) -> [conv(N) || <<N:4>> <= Binary].

conv(N) when N < 10 -> N + 48; 
conv(N) -> N + 87. 
	