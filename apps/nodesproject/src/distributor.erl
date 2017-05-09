-module(distributor).
-export([start/0,
	 get_workers/0,
	 get_least_busy_node/0,
	 starts_with_alice_or_bob/1,
	 get_length/1]).
-compile(export_all).


start()->
    Pid = spawn(fun()-> loop() end),
    register(distributor,Pid),
    Pid.

loop() ->
    receive
	{Caller, Task, Ref} ->
	    Least_busy_node = get_least_busy_node(),
	    io:format(user,"got the task ~p sending it to ~p~n ",[Task, Least_busy_node]),
	    file:write_file(".tmp/distributoroutput.txt", io_lib:fwrite("~p \n", [Task])),
	    {Least_busy_node, worker} ! {append, Task, Caller, Ref}
    end,
    loop().


get_workers() ->
    [N || N <- nodes(), starts_with_alice_or_bob(N)].

starts_with_alice_or_bob(Short_host) ->
    Host = atom_to_list(Short_host),
    case string:tokens(Host, "@") of
	[User, _] ->
	    lists:member(User, ["alice", "bob"]);
	_ ->
	    false
    end.    

get_least_busy_node() ->
    Workers = distributor:get_workers(),
    List = [{N, distributor:get_length(N)} || N <- Workers],
    get_node_with_least_length_value(List, {somenode@host, 9999}).

get_node_with_least_length_value([],{Node, _})->
    Node;
get_node_with_least_length_value([H|T], {Node, Lmin})->
    {Node_current,Len_current} = H,
    {Node_Res, Lmin_Res} = case Len_current < Lmin of
			       true  ->
				   {Node_current, Len_current};
			       false ->
				   {Node, Lmin}
			   end,
    get_node_with_least_length_value(T, {Node_Res, Lmin_Res}).
				   
get_length(Node) ->
    Ref = make_ref(),
    {Node, worker} ! {length, self(), Ref},
    receive
	{L, Ref} ->
	    L
    end.
