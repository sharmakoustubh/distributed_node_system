-module(caller).
-export([start/0, send_task_and_get_result/0]).

start()->
    Pid = spawn(fun()-> send_task_and_get_result()end),
    register(caller,Pid).

send_task_and_get_result()->
    {ok,Hostname} = inet:gethostname(),
    Distributor_node = list_to_atom("distributor@" ++ Hostname),
    {Distributor_node,distributor} ! {self(), fun()-> lists:seq(2,8) end, make_ref()},
    receive 
	X ->
            io:format(user,"~p~n",[X])            
    end,
    X.
    %% send_task_and_get_result().
