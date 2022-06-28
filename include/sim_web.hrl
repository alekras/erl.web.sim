-record(user,
	{
		user_id :: string(),
		contacts = [] :: list({string(), term()}), %% state keeps value is owner choose the user to talk (recently)
		state :: term() %% @todo for future 
	}
).

%%-define(URL, "http://192.168.1.75:8880").
-define(URL, "http://MacBook-Pro:8080"). % @todo move to config
%%-define(URL, "http://lucky3p.com:8880"). % @todo move to config
