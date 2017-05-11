-module(distributor).
-export([start/0,
	 get_workers/0,
	 get_least_busy_node/0,
	 starts_with_alice_or_bob/1,
	 get_length/1]).
-compile(export_all).


start()->
    spawn(fun()-> register(distributor,self()),loop() end).


loop() ->
    receive
	{Caller, Task, Ref} ->
	    io:format(user,"distributor got task ~p  ~n",[Task]),
	    file:write_file("./tmp/distributoroutput.txt", io_lib:format("received task in distributor~p\n", [Task])),
	    Least_busy_node = get_least_busy_node(),
	    io:format(user,"least busy node is  ~p  ~n",[Least_busy_node]),
	    {worker, Least_busy_node} ! {append, Task, Caller, Ref},
	    io:format(user,"sent the message append the task to worker ~n",[])
		
    end,
    loop().

get_least_busy_node() ->
    Workers = distributor:get_workers(),
    io:format(user," the workers are ~p  ~n",[Workers]),    
    List = [{N, distributor:get_length(N)} || N <- Workers],
    io:format(user," the workers with lengths  are ~p  ~n",[List]),    
    Node_Lmin = get_node_with_least_length_value(List, hd(List)),
    io:format(user," the node with least length is ~p  ~n",[Node_Lmin]),
    Node_Lmin.

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

get_length(Node) ->
    Ref = make_ref(),
    {worker, Node} ! {length, self(),node(), Ref},
    receive
	{L, Ref} ->
	    L
    end.

get_node_with_least_length_value([],{Node, Lmin})->
    Node;
get_node_with_least_length_value([H|T],{Node, Lmin})->
    {Node_current,Len_current} = H,
    {Node_Res, Lmin_Res} = case Len_current < Lmin of
			       true  ->
				   {Node_current, Len_current};
			       false ->
				   {Node, Lmin}
			   end,
    get_node_with_least_length_value(T, {Node_Res, Lmin_Res}).

