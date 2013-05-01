-module(redis_pool).
-export([start/0, stop/0]).
-export([q/2]).

start() ->
    application:start(redis_pool).

stop() ->
    application:stop(redis_pool).

%% eredis api
q(PoolName, Command) ->
    Fun = fun(Worker) ->
                  gen_server:call(Worker, {q, Command})
          end,
    poolboy:transaction(PoolName, Fun).
