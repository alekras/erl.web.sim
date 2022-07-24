%% @author alexei
%% @doc @todo Add description to sim_web_handler.


-module(sim_web_handler_cont).
-include("sim_web.hrl").

%% ====================================================================
%% API functions
%% ====================================================================
-export([init/2, contacts_json/1]).

init(Req0, Opts) ->
	lager:info("get sim/contacts: ~120p\n~120p", [Req0, Opts]),
	Method = cowboy_req:method(Req0),
	HasBody = cowboy_req:has_body(Req0),

	Req = case Opts of 
					[get_all] -> get_all_contacts(Method, Req0);
					[add] -> add_new_contact(Method, HasBody, Req0);
					[remove] -> remove_contact(Method, HasBody, Req0)
				end,
	{ok, Req, Opts}.
%% ====================================================================
%% Internal functions
%% ====================================================================

get_all_contacts(<<"GET">>, Req) ->
	User = cowboy_req:binding(user_name, Req),
	lager:info("get contacts/:user_name/get_all, user: ~120p", [User]),
	if (User =:= undefined) ->
			cowboy_req:reply(400, #{}, <<"Wrong request.">>, Req);
		true ->
			make_reply_get_all(binary:bin_to_list(User), Req)
	end;
get_all_contacts(_, Req) ->
	%% Method not allowed.
	cowboy_req:reply(405, Req).

add_new_contact(<<"POST">>, false, Req) ->
	User = cowboy_req:binding(user_name, Req),
	New_Contact = cowboy_req:binding(new_contact, Req),
	lager:info("get /sim/contacts/:user_name/add/:new_contact, user: ~120p; new contact: ~120p", [User, New_Contact]),
	if (User =:= undefined) or (New_Contact =:= undefined) ->
			cowboy_req:reply(400, #{}, <<"Wrong request.">>, Req);
		true ->
			make_reply_for_add(binary:bin_to_list(User), binary:bin_to_list(New_Contact), Req)
	end;
add_new_contact(<<"POST">>, true, Req) ->
	cowboy_req:reply(400, #{}, <<"Not empty body.">>, Req);
add_new_contact(_, _, Req) ->
	%% Method not allowed.
	cowboy_req:reply(405, Req).

remove_contact(<<"POST">>, false, Req) ->
	User = cowboy_req:binding(user_name, Req),
	Contact_to_del = cowboy_req:binding(contact_name, Req),
	lager:info("get /sim/contacts/:user_name/remove/:new_contact, user: ~120p; new contact: ~120p", [User, Contact_to_del]),
	if (User =:= undefined) or (Contact_to_del =:= undefined) ->
			cowboy_req:reply(400, #{}, <<"Wrong request.">>, Req);
		true ->
			make_reply_for_remove(binary:bin_to_list(User), binary:bin_to_list(Contact_to_del), Req)
	end;
remove_contact(<<"POST">>, true, Req) ->
	cowboy_req:reply(400, #{}, <<"Not empty body.">>, Req);
remove_contact(_, _, Req) ->
	%% Method not allowed.
	cowboy_req:reply(405, Req).

make_reply_get_all(User, Req) ->
	case sim_web_dets_dao:get(User) of
		#user{user_id = User, contacts = Contacts} ->
			L = contacts_json(Contacts),
			lager:info("~n --- Contacts: ~p~n --- Json: ~p~n", [Contacts, L]),
			cowboy_req:reply(200, #{
						<<"content-type">> => <<"application/json">>
					}, L, Req);
		_ ->
			cowboy_req:reply(200, #{
						<<"content-type">> => <<"application/json">>
					}, <<"{\"status\":\"fail\", \"reason\":\"not_exist\"}">>, Req)
	end.

rest_req_isconnected(User) ->
	Host = application:get_env(sim_web, mqtt_rest_url, "http://localhost:18080"),
	Url = string:replace(Host ++ "/rest/user/" ++ User ++ "/status", " ", "%20", all),
%%	lager:info("URL encoded: ~p", [Url]),
	ReqTo0 = {Url, [{"X-Forwarded-For", "localhost"}, {"Accept", "application/json"}, {"X-API-Key", "mqtt-rest-api"}]},
	ConnStatus =
	case httpc:request(get, ReqTo0, [], []) of
		{ok, {{_Pr, Status, _}, _Headers, Body}} ->
			case Status of
				200 -> 
					lager:debug("Body from MQTT: ~p~n",[Body]),
					Json_Body = jsx:decode(binary:list_to_bin(Body), [return_maps]),
					binary:bin_to_list(maps:get(<<"status">>, Json_Body, <<"notFound">>));
				404 -> "notFound"
			end;
		{error, _Reason} ->
			lager:error("Conection error: ~p", [_Reason]),
			"notFound";
		_R -> 
			lager:error("Conection error. Responce: ~p", [_R]),
			"notFound"
	end,
	lager:info("get /rest/user/:user_name/isconnected, user_name: ~p Connection status: ~p", [User, ConnStatus]),
	ConnStatus.
	
contacts_json(Contacts_list) ->
	L = [ 
		begin
			Status = rest_req_isconnected(Contact),
			lists:concat(["\"", Contact, "\":{\"status\":\"", Status, "\"}"])
		end	|| Contact <- Contacts_list
	],
	"{\"status\":\"ok\",\"contacts\":{"
		++ lists:flatten(lists:join(",", L))
		++ "}}".

make_reply_for_add(User, New_Contact, Req) ->
	case rest_req_isconnected(New_Contact) of
		undefined ->
			cowboy_req:reply(200, #{
						<<"content-type">> => <<"application/json">>
					}, <<"{\"status\":\"fail\", \"reason\":\"not_exist\"}">>, Req);
		Status ->
			L =
				case sim_web_dets_dao:get(User) of
					#user{user_id = User, contacts = Contacts} = UserRec ->
						NewContacts =
							case lists:member(New_Contact, Contacts) of
								true -> Contacts;
								false -> 	[New_Contact | Contacts]
							end,
						sim_web_dets_dao:save(UserRec#user{contacts = NewContacts}),
						contacts_json(NewContacts);
					_ ->
						sim_web_dets_dao:save(#user{user_id = User, contacts = [New_Contact]}),
					"{\"status\":\"ok\",\"contacts\":[{\"id\":\"" ++ New_Contact ++ "\",\"status\":\"" ++ Status ++ "\"}]}"
				end,
			cowboy_req:reply(200, #{
						<<"content-type">> => <<"application/json">>
					}, L, Req)
	end.

make_reply_for_remove(User, Contact_to_remove, Req) ->
	case sim_web_dets_dao:get(User) of
		#user{user_id = User, contacts = Contacts} = UserRec ->
			NewContacts = lists:delete(Contact_to_remove, Contacts),
			sim_web_dets_dao:save(UserRec#user{contacts = NewContacts}),
			L = contacts_json(NewContacts),
			cowboy_req:reply(200, #{
						<<"content-type">> => <<"application/json">>
					}, L, Req);
		_ ->
			cowboy_req:reply(200, #{
						<<"content-type">> => <<"application/json">>
					}, <<"{\"status\":\"fail\"}">>, Req)
	end.
