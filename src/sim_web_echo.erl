%% @author alexei
%% @doc @todo Add description to sim_web_echo.

-module(sim_web_echo).
-include_lib("mqtt_common/include/mqtt.hrl").

%% ====================================================================
%% API functions
%% ====================================================================
-export([callback/1, pingCallback/1, start/0, stop/0, loop/1]).
-record(state, {connection::pid()}).

start() ->
	R = application:ensure_started(mqtt_client),
	lager:debug("MQTT client application started with:~p~n", [R]),
	
	Port = application:get_env(sim_web, mqtt_port, 8880),
	Host = application:get_env(sim_web, mqtt_host, "localhost"),
	ConnType = application:get_env(sim_web, mqtt_conn_type, web_socket),
	ConnectionPid = mqtt_client:connect(
		echo, 
		#connect{client_id = "echo", user_name = "echo", password = <<"echo">>, keep_alive = 6000000, version = '3.1'}, 
		Host, 
		Port, 
		[{conn_type, ConnType}]
	),
	lager:debug("Echo >>> connection established. Host:~p Port:~p Type:~p PID:~p~n", [Host, Port, ConnType, ConnectionPid]),

	mqtt_client:subscribe(ConnectionPid, [{"/echo/+", 2, {?MODULE, callback}}]),

	Pid = spawn_link(?MODULE, loop, [#state{connection = ConnectionPid}]),
	register(echo_srvs, Pid),
	{ok, Pid}.

stop() -> 
	echo_srvs ! stop,
	unregister(echo_srvs).


%% ====================================================================
%% Internal functions
%% ====================================================================

loop(#state{connection = Conn} = State) ->
	lager:debug("Echo >>> loop echo_srvs: ~p | conn status: ~p~n", [lists:member(echo_srvs, registered()),mqtt_client:status(Conn)]),
	receive
		stop -> ok;
		{send, Topic, Msg} ->
			mqtt_client:publish(Conn, #publish{topic = Topic, qos = 2}, Msg),
			loop(State)
	after
		120000 ->
			case mqtt_client:status(Conn) of
				disconnected -> 
					lager:debug("Echo >>> terminate: connection PID:~p Status:~p~n", [Conn, mqtt_client:status(Conn)]),
					unregister(echo_srvs);
				Status ->
					mqtt_client:pingreq(Conn, {?MODULE, pingCallback}),
					lager:debug("Echo >>> Connection status:~p~n",[Status]),
					loop(State)
			end
	end.

pingCallback(A) ->
	lager:debug("Ping:~p~n",[A]).

callback({_Q, #publish{topic= Topic, qos=_QoS, dup=_Dup, payload= Msg}} = _Arg) ->
	lager:debug("Echo >>> got message: ~p~n", [_Arg]),
	Segments = string:split(Topic, "/", all),
	NewTopic = "/" ++ lists:nth(3, Segments) ++ "/" ++ lists:nth(2, Segments),
	lager:debug("Echo >>> send message to topic: ~p~n", [NewTopic]),
	echo_srvs ! {send, NewTopic, Msg}.
