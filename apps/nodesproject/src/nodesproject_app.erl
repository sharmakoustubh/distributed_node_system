%%%-------------------------------------------------------------------
%% @doc nodesproject public API
%% @end
%%%-------------------------------------------------------------------

-module(nodesproject_app).

-behaviour(application).

%% Application callbacks
-export([stop/1]).

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
    nodesproject_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================

start(Node)->
  Res =  check_node_exists(Node),
   case Res of 
       true ->
	  
	   case Node of
	       distributor ->
		   distributor:start();
	       caller ->
		   caller:start();
	       _->
		   worker:start()
	   end;
       false ->
	   io:format("given role ~p does not exit~n",[Node])
   end.

give_node_name(Type)->
    net_kernel:start([Type, shortnames]).

check_node_exists(Node)->
    List = [bob,alice,distributor,caller],
    lists:member(Node,List).
    
