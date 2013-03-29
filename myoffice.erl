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
         user_offline/1
        ]).

init(Context) ->
    application:start(buffalo),
    application:set_env(ouroffice, mac_lookup, fun ?MODULE:user_lookup/1),
    application:set_env(ouroffice, notifier_module, ?MODULE),
    ouroffice_sup:start_link(),
    ok.

user_lookup(Mac) ->
    m_dets:lookup(mac_to_user, Mac, z:c(?MODULE)).

user_online(User, _FirstTime) ->
    lager:warning("online: ~p", [User]),
    ok.

user_offline(User) ->
    lager:warning("offline: ~p", [User]),
    ok.


event(#submit{message={update, [{mac, Mac}]}}, Context) ->
    User = [{name, z_context:get_q("name", Context)},
            {gender, map_gender(z_context:get_q("gender", Context))}],
    lager:warning("User: ~p", [User]),
    m_dets:insert(mac_to_user, Mac, User, Context),
    z_render:wire([{reload, []}], Context);

event(#postback{message={remove, [{mac, Mac}]}}, Context) ->
    m_dets:delete(mac_to_user, Mac, Context),
    z_render:wire([{reload, []}], Context).


map_gender("F") -> f;
map_gender(_) -> m.
