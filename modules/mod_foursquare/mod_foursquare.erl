-module(mod_foursquare).
-author("Arjan Scherpenisse").

-mod_title("Foursquare").
-mod_description("Implements Foursquare OAuth 2.0 authentication").
-mod_prio(20).

-include_lib("zotonic.hrl").

-export([init/1, redirect_uri/1]).

%%====================================================================
%% support functions go here
%%====================================================================

init(_Context) ->
    ok.


redirect_uri(Context) ->
    z_context:abs_url(z_dispatcher:url_for(foursquare_callback, [], Context), Context).
