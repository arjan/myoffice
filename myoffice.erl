%% @author Arjan Scherpenisse
%% @copyright 2013 Arjan Scherpenisse
%% Generated on 2013-03-29
%% @doc This site was based on the 'nodb' skeleton.

%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%% 
%%     http://www.apache.org/licenses/LICENSE-2.0
%% 
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.

-module(myoffice).
-author("Arjan Scherpenisse").

-mod_title("myoffice zotonic site").
-mod_description("A Zotonic site without database.").
-mod_prio(10).

-include_lib("zotonic.hrl").

-export([init/1,
         event/2,
         user_lookup/1,
         user_online/2,
         user_offline/1,
         current_user/1,
         set_access_token/2,
         do_foursquare_checkin/2
        ]).

init(Context) ->
    application:start(buffalo),

    reconfigure(Context),

    application:set_env(ouroffice, mac_lookup, fun ?MODULE:user_lookup/1),
    application:set_env(ouroffice, notifier_module, ?MODULE),
    ouroffice_sup:start_link(),
    ok.

user_lookup(Mac) ->
    m_dets:lookup(mac_to_user, Mac, z:c(?MODULE)).

user_online(User, true) ->
    lager:warning("ignore: ~p", [User]);

user_online(User, false) ->
    %% Do foursquare here
    case proplists:get_value(foursquare_access_token, User) of
        undefined -> nop;
        Token ->
            Context = z:c(?MODULE),
            do_foursquare_checkin(Token, Context),
            ok
    end,
    %% And forward to the real notifier
    ouroffice_notifier:user_online(User, false),
    ok.

user_offline(User) ->
    %% Just forward to the real notifier
    ouroffice_notifier:user_offline(User),
    ok.


do_foursquare_checkin(Token, Context) ->
    Venue = m_myoffice:get_config(foursquare_venue, Context),
    Url = "https://api.foursquare.com/v2/checkins/add",
    Body = "venueId=" ++ z_convert:to_list(Venue)
        ++ "&oauth_token=" ++ Token,
    {ok, R} = httpc:request(post, {Url, [], "application/x-www-form-urlencoded", Body}, [], []),
    lager:warning("R: ~p", [R]),
    ok.
    

set_access_token(AccessToken, Context) ->
    User = myoffice:current_user(Context),
    NewUser = case AccessToken of
                  undefined ->
                      proplists:delete(foursquare_access_token, User);
                  _ ->
                      z_utils:prop_replace(foursquare_access_token, AccessToken, User)
              end,
    m_dets:insert(mac_to_user, m_myoffice:macaddr(Context), NewUser, Context).


current_user(Context) ->
    user_lookup(m_myoffice:macaddr(Context)).

event(#submit{message={update, [{mac, Mac}]}}, Context) ->
    User = [{name, z_context:get_q("name", Context)},
            {gender, map_gender(z_context:get_q("gender", Context))}],
    lager:warning("User: ~p", [User]),
    m_dets:insert(mac_to_user, Mac, User, Context),
    z_render:wire([{reload, []}], Context);

event(#postback{message={remove, [{mac, Mac}]}}, Context) ->
    m_dets:delete(mac_to_user, Mac, Context),
    z_render:wire([{reload, []}], Context);

event(#postback{message={remove_foursquare, [{mac, _Mac}]}}, Context) ->
    set_access_token(undefined, Context),
    z_render:wire([{reload, []}], Context);

event(#submit{message={configure, []}}, Context) ->
    %% Save all values; reconfigure afterwards
    Save = ["foursquare_client_id", "foursquare_client_secret", "foursquare_venue",
            "twitter_ckey", "twitter_csec", "twitter_token", "twitter_secret"],
    [m_myoffice:set_config(K, z_context:get_q_validated(K, Context), Context) || K <- Save],
    reconfigure(Context),
    z_render:wire([{redirect, [{url, "/"}]}], Context).
    

reconfigure(Context) ->
    lists:foreach(
      fun(K) ->
              application:set_env(ouroffice, list_to_atom(K), m_myoffice:get_config(K, Context))
      end,
      ["twitter_ckey", "twitter_csec", "twitter_token", "twitter_secret"]),
    ok.

map_gender("F") -> f;
map_gender(_) -> m.
