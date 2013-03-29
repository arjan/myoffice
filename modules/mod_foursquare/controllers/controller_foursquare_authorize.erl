
-module(controller_foursquare_authorize).
-author("Arjan Scherpenisse <arjan@scherpenisse.net>").

-export([init/1, service_available/2, charsets_provided/2, content_types_provided/2]).
-export([resource_exists/2, previously_existed/2, moved_temporarily/2]).

-include_lib("controller_webmachine_helper.hrl").
-include_lib("include/zotonic.hrl").

init(DispatchArgs) -> {ok, DispatchArgs}.

service_available(ReqData, DispatchArgs) when is_list(DispatchArgs) ->
    Context  = z_context:new(ReqData, ?MODULE),
    Context1 = z_context:set(DispatchArgs, Context),
    Context2 = z_context:ensure_all(Context1),
    ?WM_REPLY(true, Context2).

charsets_provided(ReqData, Context) ->
    {[{"utf-8", fun(X) -> X end}], ReqData, Context}.

content_types_provided(ReqData, Context) ->
    {[{"text/html", provide_content}], ReqData, Context}.

resource_exists(ReqData, Context) ->
    {false, ReqData, Context}.

previously_existed(ReqData, Context) ->
    {true, ReqData, Context}.

moved_temporarily(ReqData, Context) ->
    Context1 = ?WM_REQ(ReqData, Context),
    RedirectUrl = mod_foursquare:redirect_uri(Context1),
    
    Location = "https://foursquare.com/oauth2/authenticate?client_id="
        ++ z_convert:to_list(m_myoffice:get_config(foursquare_client_id, Context))
        ++ "&response_type=code"
        ++ "&redirect_uri=" ++ z_convert:to_list(z_utils:url_encode(RedirectUrl)),
    lager:warning("Location: ~p", [Location]),
    ?WM_REPLY({true, Location}, Context1).
