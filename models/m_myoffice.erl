
-module(m_myoffice).

-behaviour(gen_model).

%% interface functions
-export([
         m_find_value/3,
         m_to_list/2,
         m_value/2,
         macaddr/1
]).

-include_lib("zotonic.hrl").


%% @doc Fetch the value for the key from a model source
%% @spec m_find_value(Key, Source, Context) -> term()
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

