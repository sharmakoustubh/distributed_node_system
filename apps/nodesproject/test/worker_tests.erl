-module(worker_tests).
-include_lib("eunit/include/eunit.hrl").


worker_test_()->
    {foreach,
     fun setup/0,
     fun cleanup/1,
     [
      {"add to the task queue", fun adding_to_the_queue/0},
      {"add to the queue and execute", fun adding_to_the_queue_and_execute/0},
      {"add to the queue and check length", fun adding_to_queue_and_check_length/0}
     ]}.

setup()->
    ok = worker:start().
  
cleanup(_)->
    exit(whereis(worker),kill),
    ensure_exited(worker),
    exit(whereis(execute),kill),
    ensure_exited(execute),
    exit(whereis(tasks),kill),
    ensure_exited(tasks).

ensure_exited(Process) ->
    case whereis(Process) of
	undefined ->
	    ok;
	_ ->
	    ensure_exited(Process)
    end.

adding_to_the_queue()->
    F = fun()-> lists:seq(2,7) end,
    Ref = make_ref(),
    worker ! {append, F, self(), Ref},
    Result = receive
		 {X, Ref} ->
		     X
	     after 5000 ->
		     no_response_received
	     end,
    ?assertEqual(appended,Result).    

adding_to_the_queue_and_execute()->
    F = fun()-> lists:seq(2,7) end,
    Ref = make_ref(),
    worker ! {append, F, self(), Ref},
    Result1 = receive
		  {X1, Ref} ->
		      X1
	      after 50 ->
		      no_response_received
	      end,
    ?assertEqual(appended,Result1),
    Result2 = receive
		  {X2, Ref} ->
		      X2
	      after 2000 ->
		      no_response_received
	     end,
    ?assertEqual(F(),Result2).    

adding_to_queue_and_check_length()->
    F = fun()-> lists:seq(2,7) end,
    Ref = make_ref(),
    worker ! {append, F, self(), Ref},
    Result = receive
		 {X, Ref} ->
		     X
	     after 50 ->
		     no_response_received
	     end,
    ?assertEqual(appended,Result),
    Ref2 = make_ref(),
    worker ! {length, self(), Ref2},
    Result2 = receive
		  {L, Ref2} ->
		      L
	      after 2000->
		      no_response_received
	      end,
    ?assertEqual(0, Result2).



