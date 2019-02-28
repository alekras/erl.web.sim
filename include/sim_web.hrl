-record(user,
	{
		user_id :: string(),
		contacts = [] :: [string()],
		state :: atom()
	}
).

%%-define(URL, "http://192.168.1.75:8880").
-define(URL, "http://localhost:8880").
