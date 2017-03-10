-module(worker_tests).
-include_lib("eunit/include/eunit.hrl").


adding_to_the_queue_test()->
    F = fun()-> lists:seq(2,7) end,
    worker:add(F),
    Result = worker:pop(),
    ?assertEqual(F,Result).
    
