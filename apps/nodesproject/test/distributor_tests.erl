-module(distributor_tests).
-include_lib("eunit/include/eunit.hrl").


distributor_test_()->
    {foreach,
     fun setup/0,
     fun cleanup/1,
     [
    %%  {"check you get bob and alice", fun get_nodes/0}
   %%   {"get least busy nodes", fun find_node_with_lesser_tasks/0},
     ]}.

setup()->
    ok = worker:start(),
    distributor:start().
    
  
cleanup(_)->
    exit(whereis(worker),kill),
    ensure_exited(worker),
    exit(whereis(execute),kill),
    ensure_exited(execute),
    exit(whereis(tasks),kill),
    ensure_exited(tasks),
    exit(whereis(distributor),kill),
    ensure_exited(distributor).

ensure_exited(Process) ->
    case whereis(Process) of
	undefined ->
	    ok;
	_ ->
	    ensure_exited(Process)
    end.

%% get_nodes() ->
%%     Res = distributor:get_nodes(),
%%     ?assertMatch([bob,alice],Res).
    

%% find_node_with_lesser_tasks() ->
%%     F = fun()-> lists:seq(2,7) end,
%%     Ref = make_ref(),
%%     worker ! {append, F, self(), Ref},
%%     Result1 = receive
%% 		  {X1, Ref} ->
%% 		      X1
%% 	      after 50 ->
%% 		      no_response_received
%% 	      end,
%%     ?assertEqual(appended,Result1),
%%     Result2 = receive
%% 		  {X2, Ref} ->
%% 		      X2
%% 	      after 2000 ->
%% 		      no_response_received
%% 	     end,
%%     ?assertEqual(F(),Result2),
%%     distributor:get_least_busy_node(nodes(),[], 9999).
    
    













%% %% adding_to_the_queue()->
%% %%     F = fun()-> lists:seq(2,7) end,
%% %%     Ref = make_ref(),
%% %%     worker ! {append, F, self(), Ref},
%% %%     Result = receive
%% %% 		 {X, Ref} ->
%% %% 		     X
%% %% 	     after 5000 ->
%% %% 		     no_response_received
%% %% 	     end,
%% %%     ?assertEqual(appended,Result).    

%% %% adding_to_the_queue_and_execute()->
%% %%     F = fun()-> lists:seq(2,7) end,
%% %%     Ref = make_ref(),
%% %%     worker ! {append, F, self(), Ref},
%% %%     Result1 = receive
%% %% 		  {X1, Ref} ->
%% %% 		      X1
%% %% 	      after 50 ->
%% %% 		      no_response_received
%% %% 	      end,
%% %%     ?assertEqual(appended,Result1),
%% %%     Result2 = receive
%% %% 		  {X2, Ref} ->
%% %% 		      X2
%% %% 	      after 2000 ->
%% %% 		      no_response_received
%% %% 	     end,
%% %%     ?assertEqual(F(),Result2).    

%% %% adding_to_queue_and_check_length()->
%% %%     F = fun()-> lists:seq(2,7) end,
%% %%     Ref = make_ref(),
%% %%     worker ! {append, F, self(), Ref},
%% %%     Result = receive
%% %% 		 {X, Ref} ->
%% %% 		     X
%% %% 	     after 50 ->
%% %% 		     no_response_received
%% %% 	     end,
%% %%     ?assertEqual(appended,Result),
%% %%     Ref2 = make_ref(),
%% %%     worker ! {length, self(), Ref2},
%% %%     Result2 = receive
%% %% 		  {L, Ref2} ->
%% %% 		      L
%% %% 	      after 2000->
%% %% 		      no_response_received
%% %% 	      end,
%% %%     ?assertEqual(0, Result2).



