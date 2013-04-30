-module(redis_pool).
-behavior(application).
-behavior(supervisor).

-export([start/0, stop/0]).
-export([start/2, stop/1]).
-export([init/1]).

-export([q/2]).

start() ->
    application:start(?MODULE).

stop() ->
    application:stop(?MODULE).

start(_Type, _Args) ->
    supervisor:start_link({local, redis_pool}, ?MODULE, []).

stop(_State) ->
    ok.

init([]) ->
    {ok, Pools} = application:get_env(redis_pool, pools),
    MapFun = fun({Name, SizeArgs, WorkerArgs}) ->
                     PoolArgs = [{name, {local, Name}},
                                 {worker_module, redis_worker}] ++ SizeArgs,
                     poolboy:child_spec(Name, PoolArgs, WorkerArgs)
             end,
    PoolSpecs = lists:map(MapFun, Pools),
    {ok, {{one_for_one, 10, 10}, PoolSpecs}}.

q(PoolName, Command) ->
    Fun = fun(Worker) ->
                  gen_server:call(Worker, {q, Command})
          end,
    poolboy:transaction(PoolName, Fun).
