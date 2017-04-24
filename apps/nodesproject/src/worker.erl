-module(worker).
-compile(export_all).
-define(One_sec, 1000000).

start() ->
    establish_connection(),
    spawn_and_register_process(fun listen_to_distributor/0,worker),
    spawn_and_register_process(fun() -> maintain_tasks_list([]) end, tasks),
    spawn_and_register_process(fun execute_tasks/0,execute).

spawn_and_register_process(Function, Name)->
    Ref = make_ref(),
    Parent = self(),
    spawn(fun() ->
		  Pid = spawn(Function),
		  register(Name, Pid),
		  Parent ! {ok, Ref}
	  end),
    receive 
	{ok, Ref} ->
	    ok
    after
	50 ->
	    {error, "could not start process"}
    end.
    

establish_connection()->  
  %  erlang:set_cookie(node(),distribute),  
    {ok,Hostname} = inet:gethostname(),
    Host = "distributor@" ++ Hostname,
    net_kernel:connect_node(list_to_atom(Host)).

listen_to_distributor() ->
    receive
	{append, Task, Pid, Ref}->
	    tasks! {append,Task, Pid, Ref};
	{length,Pid,Ref} ->
	    tasks! {length,Pid,Ref}
    end,
    listen_to_distributor().

maintain_tasks_list(Tasks_list) ->
    Now = os:timestamp(),
    {Old_tasks, New_tasks} = lists:partition(fun({_, _, _, Timestamp}) ->
						     timer:now_diff(Now, Timestamp) > ?One_sec 
					     end, Tasks_list),    
    send_checkout_for_old_tasks(Old_tasks),
    New_tasks_list =  receive 
			  {append,X,From,Ref}->
			      Updated_tasks_list = lists:append(New_tasks,[{X, From, Ref, os:timestamp()}]),
			      From ! {appended, Ref},
			      Updated_tasks_list;
			  {pop,From,Ref} ->
			      case New_tasks of
				  [H|T] ->
				      From ! {H, Ref},
				      T; 
				  [] ->
				      From ! {empty, Ref},
				      []
			      end;
			  {length,From,Ref} ->
			      From ! {length(New_tasks),Ref},		
			      New_tasks
		      end,
    maintain_tasks_list(New_tasks_list).

send_checkout_for_old_tasks([])->
    do_nothing;

send_checkout_for_old_tasks([{Fun, From, Ref, Time}|Tasks])->
    From ! io:format("Task ~p with Ref  ~p registered at time ~p took longer than 1 sec to execute ~n", [Fun, Ref, Time]),
    send_checkout_for_old_tasks(Tasks).

execute_tasks()->
    Ref = make_ref(),
    tasks ! {pop,self(),Ref},    
    receive
	{empty, Ref} ->
	    ok;
	{{Task, From, Ref2, _},Ref} ->
	    case Task() of
		{error,Error}->
		    Error;
		Result ->
		    From ! {Result, Ref2}
	    end
    end,
    execute_tasks().


    
