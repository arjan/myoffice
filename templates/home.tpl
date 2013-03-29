{% extends "base.tpl" %}

{% block content %}

    {% if not m.myoffice.config.twitter_token %}
        {% javascript %}document.location = '/configure';{% endjavascript %}
    {% endif %}

    {% with m.myoffice.macaddr as mac %}
        {% if not mac %}
            <div class="alert alert-info">
            <h1>Oops...</h1>
            <p>We were unable to determine your MAC address. You can not use the notifier from this device.</p>
            </div>
        {% else %}
        {% with m.dets.mac_to_user.lookup[mac] as user %}

            <h2>Hi, {{ user.name|default:mac }}!</h2>

            {% if user %}
                <p>You have linked this computer to the @ouroffice notifier. Your MAC address is <em>{{ mac }}</em>.</p>

                {% button class="btn btn-primary" text="Update your details"
                    action={replace title="Update your details" template="_dialog_create.tpl" user=user mac=mac}
                %}

                {% if not user.foursquare_access_token %}
                    {% button class="btn" text="Connect to Foursquare"
                        action={redirect dispatch=`foursquare_authorize`}
                    %}
                {% else %}
                {% button class="btn" text="Remove Foursquare access"
                    action={confirm text="Are you sure you want to remove yourself from the Foursquare checkins?" postback={remove_foursquare mac=mac} delegate=`myoffice`}
                %}

                {% endif %}

                {% button class="btn btn-danger" text="Remove" class="pull-right"
                    action={confirm text="Are you sure you want to remove yourself from the notifier?" postback={remove mac=mac} delegate=`myoffice`}
                %}

            {% else %}
                <p>You are not yet known to us.</p>
                <p>
                    {% button class="btn btn-primary" text="Create your identity now"
                        action={replace title="Create identity" template="_dialog_create.tpl" mac=mac new}
                    %}
                </p>
            {% endif %}

        {% endwith %}
    {% endif %}


    <h3>All users</h3>
    <ul>
    {% for mac, user in m.dets.mac_to_user.list %}
        <li>{{ user.name }} {{ mac }}</li>
    {% endfor %}

    {% endwith %}

{% endblock %}
