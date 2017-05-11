-module(caller).
-export([start/0]).

start()->
    Pid =  spawn(fun() -> print_result() end),
    register(caller_result,Pid).


print_result()->
    receive 
        X ->
            io:format("~p~n",[X])            
    end,
    print_result().


%print_result()-> receive X-> io:format("~p~n",[X]) end, print_result().
