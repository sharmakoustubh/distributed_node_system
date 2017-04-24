-module(distributor).
-export([start/0]).


start()->
    Pid = spawn(fun()-> listen_to_caller()end),
    register(distributor,Pid),
    erlang:set_cookie(node(),distribute).


listen_to_caller()->
    Ref = make_ref(),
    receive
        Task ->
    	    Nodes = get_nodes(),
    	    Node = get_least_busy_node(Nodes, [], 9999),
    	    {worker,Node} ! {append, Task, self(), Ref}
    end,
    listen_to_caller().

get_least_busy_node([], Least_busy_node, _) ->
    Least_busy_node;

get_least_busy_node([Node|Nodes], Least_busy_node, Lmin) ->
    Ref = make_ref(),
    {worker,Node} ! {length, self(), Ref},
    receive
	{L,Ref} ->
	    case L =< Lmin of
		true ->
		Least_busy_node = Node,
		Lmin = L;
		_ -> 
		   do_nothing
	    end
    end,
get_least_busy_node([Node|Nodes], Least_busy_node, Lmin).
	    
    
get_nodes()->
    List_of_nodes =  nodes(),
    lists:flatten(filter_nodes(List_of_nodes, [])).
    
filter_nodes([], Acc)->
    Acc;

filter_nodes([N|Nodes], Acc)->
    case string:str(atom_to_list(N)) of
	"bob" ->
	    Acc = Acc ++ N;
	"alice" ->
	    Acc = Acc ++ N
    end,
    filter_nodes([Nodes], Acc).
