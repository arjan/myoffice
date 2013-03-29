<h1>Office Notifier configuration</h1>

<p>Welcome to your office notification daemon. We need you to enter a few configuration options.</p>


{% wire type="submit" id=#create postback={configure} delegate=`myoffice` %}
<form id="{{ #create }}" action="postback" method="post" class="form-horizontal">

    {% include "_config_group.tpl"
        caption="Foursquare configuration"
        expl="Enter the details for Foursquare. <a href='https://foursquare.com/developers/apps'>Go here</a> to create a Foursquare app first."
        fields=[["foursquare_client_id", "App Client ID"], ["foursquare_client_secret", "App Client secret"], ["foursquare_venue", "Foursquare venue ID"]]
    %}

    {% include "_config_group.tpl"
        caption="Twitter configuration"
        expl="Enter the details for Twitter. <a href='https://dev.twitter.com/apps'>Go here</a> to create a Twitter app first."
        fields=[["twitter_ckey", "Consumer key"], ["twitter_csec", "Consumer secret"], ["twitter_token", "Authorized token"], ["twitter_secret", "Token secret"]]
    %}

    <div class="control-group">
        <div class="controls">

            <button class="btn btn-primary" type="submit">{_ Submit _}</button>
        </div>
    </div>
</form>

