-module(worker).
-compile(export_all).
-define(One_sec, 1000000).

start() ->
    connection_establisher(),
    Pid1 = spawn(fun()-> listen_to_distributor() end),
    register(worker,Pid1),
    Pid2 = spawn(fun()-> maintain_tasks_list([]) end),
    register(tasks, Pid2),
    Pid3 = spawn(fun()-> execute_tasks() end),
    register(execute, Pid3).
    
connection_establisher()->    
    {ok,Hostname} = inet:gethostname(),
    Host = "distributor@" ++ Hostname,
    net_kernel:connect_node(list_to_atom(Host)).

listen_to_distributor() ->
    receive
	{task, Task, Pid, Ref}->
	    tasks! {append,Task, Pid, Ref};
	{length,Pid,Ref} ->
	    tasks! {length,Pid,Ref}
    end,
    listen_to_distributor().

maintain_tasks_list(Tasks_list) ->
    Now = os:timestamp(),
    
    {Old_tasks, New_tasks} = lists:partition(fun({_, _, Timestamp}) ->
						     timer:now_diff(Now, Timestamp) > ?One_sec 
					     end, Tasks_list),    
    send_checkout_for_old_tasks(Old_tasks),
    
    receive 
	{append,X,From,Ref}->
	    Updated_tasks_list = lists:append(New_tasks,[{X,Ref,os:timestamp()}]),
	    From ! {appended, Ref},
	    maintain_tasks_list(Updated_tasks_list);
	{pop,From,Ref} ->
	    [H,T]= New_tasks,
	    From ! {H, Ref},
	    maintain_tasks_list(T);
	{length,From,Ref} ->
	    From ! {length(New_tasks),Ref},		
	    maintain_tasks_list(New_tasks)
    end.

send_checkout_for_old_tasks(Old_tasks)->
    {checked_out_tasks, Old_tasks}.

execute_tasks()->
    Ref = make_ref(),
    tasks ! {pop,self(),Ref},    
    receive
	{Task,Ref} ->
	    case Task() of
		{error,Error}->
		    Error;
		Result ->
		    caller ! Result
	    end
    after 5000 ->
	    do_nothing
    end,
    execute_tasks().


    
