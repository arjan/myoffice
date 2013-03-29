
-module(m_myoffice).

-behaviour(gen_model).

%% interface functions
-export([
         m_find_value/3,
         m_to_list/2,
         m_value/2,
         macaddr/1,
         get_config/2,
         set_config/3
]).

-include_lib("zotonic.hrl").


%% @doc Fetch the value for the key from a model source
%% @spec m_find_value(Key, Source, Context) -> term()
m_find_value(config, M=#m{value=undefined}, _Context) ->
    M#m{value=config};
m_find_value(Key, #m{value=config}, Context) ->
    get_config(Key, Context);
m_find_value(macaddr, #m{value=undefined}, Context) ->
    macaddr(Context).


%% @doc Transform a m_config value to a list, used for template loops
%% @spec m_to_list(Source, Context) -> List
m_to_list(_, _Context) ->
    [].

%% @doc Transform a model value so that it can be formatted or piped through filters
%% @spec m_value(Source, Context) -> term()
m_value(#m{value=undefined}, _Context) ->
    undefined.


get_config(Key, Context) ->
    Key1 = z_convert:to_atom(Key),
    m_dets:lookup(config, Key1, Context).

set_config(Key, Value, Context) ->
    Key1 = z_convert:to_atom(Key),
    m_dets:insert(config, Key1, Value, Context).


ip(Context) ->
    {IP, _} = webmachine_request:peer(z_context:get_reqdata(Context)),
    IP.

macaddr(Context) ->
    Peer = ip(Context),
    z_depcache:memo(fun() ->
                            ouroffice_scanner:macaddr(Peer)
                    end,
                    {mac, Peer},
                    Context).

