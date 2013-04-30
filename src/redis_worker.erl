-module(redis_worker).
-behavior(gen_server).
-export([start_link/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-record(state, {client}).

start_link(Args) ->
    gen_server:start_link(?MODULE, Args, []).

init(Args) ->
    Host = proplists:get_value(host, Args),
    Port = proplists:get_value(port, Args),
    {ok, Client} = eredis:start_link(Host, Port),
    {ok, #state{client = Client}}.

handle_call({q, Command}, _From, #state{client=Client} = State) ->
    {reply, eredis:q(Client, Command), State};

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, #state{client=Client}) ->
    eredis:close(Client),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
