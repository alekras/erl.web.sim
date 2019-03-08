-record(user,
	{
		user_id :: string(),
		contacts = [] :: [{user_id :: string(), state :: term()}], %% state keeps value is owner choose the user to talk (recently)
		state :: term() %% @todo for future 
	}
).

%%-define(URL, "http://192.168.1.75:8880").
-define(URL, "http://localhost:8880"). % @todo move to config
