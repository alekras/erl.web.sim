%% @author alexei
%% @doc @todo Add description to sim_web_echo.

-module(sim_echo).
-include_lib("mqtt_common/include/mqtt.hrl").

%% ====================================================================
%% API functions
%% ====================================================================
-export([callback/2, start/0, stop/0, loop/1]).
-record(state, {connectionRecord::#connect{},connection::pid()}).

start() ->
	R = application:ensure_started(mqtt_client),
	lager:debug("MQTT client application (echo) started with:~p~n", [R]),
	
	Port = application:get_env(sim_web, mqtt_port, 8880),
	Host = application:get_env(sim_web, mqtt_host, "localhost"),
	ConnType = application:get_env(sim_web, mqtt_conn_type, web_socket),
	ConnectionPid = mqtt_client:create(echo),
	ConnectionRecord =
		#connect{
			client_id = "echo",
			user_name = "echo",
			password = <<"echo">>,
			host = Host,
			port = Port,
			conn_type = ConnType,
			keep_alive = 6000000,
			version = '3.1'
		}, 

	Pid = spawn_link(?MODULE, loop, [#state{connectionRecord = ConnectionRecord, connection = ConnectionPid}]),
	register(echo_srvs, Pid),
	echo_srvs ! connect,
	{ok, Pid}.

stop() -> 
	echo_srvs ! stop.


%% ====================================================================
%% Internal functions
%% ====================================================================

loop(#state{connectionRecord = #connect{host = Host, port = Port, conn_type = ConnType} = ConnRec,
						connection = Conn} = State) ->
	lager:debug("Echo >>> loop echo_srvs: ~p | conn status: ~p ClientPid: ~p~n", 
			[lists:member(echo_srvs, registered()), mqtt_client:status(Conn), Conn]),
	receive
		connect ->
			ok = mqtt_client:connect(
				echo,
				ConnRec, 
				{?MODULE, callback}
			),
			loop(State);
		subscribe ->
			lager:debug("Echo >>> connection established. Host:~p Port:~p Type:~p ClientPID: ~p~n", 
					[Host, Port, ConnType, Conn]),
			mqtt_client:subscribe(Conn, [{"/echo/+", 2}]),
			loop(State);
		stop ->
			mqtt_client:dispose(Conn),
			unregister(echo_srvs);
		{send, Topic, Msg} ->
			mqtt_client:publish(Conn, #publish{topic = Topic, qos = 2}, Msg),
			loop(State)
	after
		120000 ->
			case mqtt_client:status(Conn) of
				disconnected -> 
					lager:debug("Echo >>> terminated: connection PID:~p Status:~p~n", [Conn, mqtt_client:status(Conn)]),
					mqtt_client:dispose(echo),
					ConnectionPid = mqtt_client:create(echo),
					echo_srvs ! connect,
					loop(State#state{connection = ConnectionPid});
				Status ->
					case proplists:get_value(connected, Status, 0) of
						0 ->
							lager:debug("Echo >>> connection closed ClientPID: ~p Status:~p~n", [Conn, mqtt_client:status(Conn)]),
							echo_srvs ! connect,
							loop(State);
						1 ->
							mqtt_client:pingreq(Conn),
							lager:debug("Echo >>> After ping. ClientPID: ~p Connection status:~p~n",[Conn, mqtt_client:status(Conn)]),
							loop(State)
					end
			end
	end.

callback(onConnect, Arg) ->
	lager:debug("Echo >>> callback got message: ~p; ~p~n", [onConnect, Arg]),
	echo_srvs ! subscribe;
callback(onReceive, {_, #publish{topic= Topic, qos=_QoS, dup=_Dup, payload= Msg}} = Arg) ->
	lager:debug("Echo >>> callback got message: ~p; ~p~n", [onReceive, Arg]),
	Segments = string:split(Topic, "/", all),
	NewTopic = "/" ++ lists:nth(3, Segments) ++ "/" ++ lists:nth(2, Segments),
	lager:debug("Echo >>> callback send message to topic: ~p~n", [NewTopic]),
	echo_srvs ! {send, NewTopic, Msg};
callback(onClose, Arg) ->
	lager:debug("Echo >>> callback got message: ~p; ~p~n", [onClose, Arg]),
	timer:sleep(20000),
	echo_srvs ! connect;
callback(onError, #mqtt_error{oper = open_socket, error_msg = econnrefused} = Arg) ->
	lager:debug("Echo >>> callback got message: ~p; ~p~n", [onError, Arg]),
	timer:sleep(20000),
	echo_srvs ! connect;
callback(Event, Arg) ->
	lager:debug("Echo >>> callback got message: ~p; ~p~n", [Event, Arg]).
