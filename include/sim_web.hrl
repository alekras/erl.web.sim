-record(user,
	{
		user_id :: string(),
		contacts = [] :: [string()],
		state :: online | offline
	}
).

%%-define(URL, "http://192.168.1.75:8880").
-define(URL, "http://localhost:8880"). % @todo move to config
