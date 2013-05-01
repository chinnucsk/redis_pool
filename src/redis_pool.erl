-module(redis_pool).
-export([q/2]).

q(PoolName, Command) ->
    Fun = fun(Worker) ->
                  gen_server:call(Worker, {q, Command})
          end,
    poolboy:transaction(PoolName, Fun).
