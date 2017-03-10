-module(worker_tests).
-include_lib("eunit/include/eunit.hrl").

worker_test_()->
    {foreach,
     fun setup/0,
     fun cleanup/1,
     [
      fun adding_to_the_queue/0,
      fun adding_to_the_queue_and_pop/0
     ]
    }.
     
setup()->
    worker:start().

cleanup(_)->
    exit(whereis(worker),kill),
    exit(whereis(tasks),kill),
    exit(whereis(execute),kill),
    ensure_exited().


ensure_exited() ->
    case whereis(worker) of
	undefined ->
	    ok;
	_ ->
	    timer:sleep(10),
	    ensure_exited()
    end,       
    case whereis(tasks) of
	undefined ->
	    ok;
	_ ->
	    timer:sleep(10),
	    ensure_exited()
    end,
    case whereis(execute) of
	undefined ->
	    ok;
	_ ->
	    timer:sleep(10),
	    ensure_exited()
    end.
    


adding_to_the_queue()->
    F = fun()-> lists:seq(2,7) end,
    Ref = make_ref(),
    worker ! {worker, F, self(), Ref},
    Result = receive
		 X ->
		     X
	     after 5000 ->
		     no_response_received
	     end,
    ?assertEqual(appended,Result).    


adding_to_the_queue_and_pop()->
    F = fun()-> lists:seq(2,7) end,
    Ref1 = make_ref(),
    worker ! {worker, F, self(), Ref1},
    Result1 = receive
		 X1 ->
		     X1
	     after 5000 ->
		     no_response_received
	     end,
    ?assertEqual(appended,Result1),
    timer:sleep(5000),
    Ref2 = make_ref(),
    worker ! {length,self(),Ref2},
    Result2 = receive
		 X2 ->
		     X2
	     after 5000 ->
		     no_response_received
	     end,
    ?assertEqual(0,Result2).    


