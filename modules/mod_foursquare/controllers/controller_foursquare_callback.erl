
-module(controller_foursquare_callback).
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
    Code = z_context:get_q("code", Context1),
    lager:warning("Code: ~p", [Code]),
    RedirectUrl = mod_foursquare:redirect_uri(Context1),

    Url = "https://foursquare.com/oauth2/access_token"
        ++ "?client_id=" ++ z_convert:to_list(m_config:get_value(mod_foursquare, client_id, Context))
        ++ "&client_secret=" ++ z_convert:to_list(m_config:get_value(mod_foursquare, client_secret, Context))
        ++ "&grant_type=authorization_code"
        ++ "&redirect_uri=" ++ z_convert:to_list(z_utils:url_encode(RedirectUrl))
        ++ "&code=" ++ z_convert:to_list(z_utils:url_encode(Code)),

    case httpc:request(get, {Url, []}, [], []) of
        {ok, {{_, 200, _}, _, Body}} ->
            {struct, Props} = mochijson:decode(Body),
            AccessToken = proplists:get_value("access_token", Props),
            myoffice:set_access_token(AccessToken, Context1),
            ok
    end,
        
    Location = "/",
    ?WM_REPLY({true, z_convert:to_list(Location)}, Context1).
