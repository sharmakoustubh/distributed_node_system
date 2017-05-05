-module(distributor_tests).
-include_lib("eunit/include/eunit.hrl").

alice_starts_with_alice_or_bob_test() ->
    Input = alice@shortname,
    Result = distributor:starts_with_alice_or_bob(Input),
    ?assertEqual(true, Result).

bob_starts_with_alice_or_bob_test() ->
    Input = bob@shortname,
    Result = distributor:starts_with_alice_or_bob(Input),
    ?assertEqual(true, Result).

carol_does_not_start_with_alice_or_bob_test() ->
    Input = carol@shortname,
    Result = distributor:starts_with_alice_or_bob(Input),
    ?assertEqual(false, Result).

an_invalid_hostname_does_not_start_with_alice_or_bob_test() ->
    Input = alkfdsjhalkfsj,
    Result = distributor:starts_with_alice_or_bob(Input),
    ?assertEqual(false, Result).


get_least_busy_node_test_() ->
    {setup,
     fun setup/0,
     fun cleanup/1,
     [ {"get the worker nodes",fun get_worker_nodes/0},
       {"get the length of the provided node",fun get_length_of_node/0},
       {"get the shortest queue",fun get_least_busy_node_should_return_worker_with_shortest_queue/0},
 {"get the short queue not bob oh bob hell not",fun get_least_busy_node_not_return_wrong_node/0}
]
    }.

setup() ->
    meck:new(distributor, [passthrough]),
    meck:expect(distributor, get_workers, fun()-> [alice@host, bob@host] end),
    meck:expect(distributor, get_length, fun(alice@host) -> 1;
					    (bob@host) -> 2
					 end).

cleanup(_) ->
    meck:unload(distributor).
    
get_worker_nodes()->
    Result = distributor:get_workers(),
    Expected = [alice@host, bob@host],
    ?assertEqual(Expected, Result).

get_length_of_node()->
    Result = distributor:get_length(bob@host),
    Expected = 2,
    ?assertEqual(Expected, Result).

get_least_busy_node_should_return_worker_with_shortest_queue() ->
    Expected = alice@host,
    Result = distributor:get_least_busy_node(),
    ?assertEqual(Expected, Result).

get_least_busy_node_not_return_wrong_node() ->
    Expected = bob@host,
    Result = distributor:get_least_busy_node(),
    ?assertNotEqual(Expected, Result).
