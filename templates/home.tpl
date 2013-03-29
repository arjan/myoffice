{% extends "base.tpl" %}

{% block content %}
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
                <p>You have linked this computer to the @ouroffice notifier.</p>

                {% button class="btn btn-primary" text="Update your details"
                    action={dialog_open title="Update your details" template="_dialog_create.tpl" user=user mac=mac}
                %}

                {% button class="btn btn-danger" text="Remove" class="pull-right"
                    action={confirm text="Are you sure you want to remove yourself from the notifier?" postback={remove mac=mac} delegate=`myoffice`}
                %}

            {% else %}
                <p>You are not yet known to us.</p>
                <p>
                    {% button class="btn btn-primary" text="Create your identity now"
                        action={dialog_open title="Create identity" template="_dialog_create.tpl" mac=mac new}
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
