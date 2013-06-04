<!DOCTYPE html>
<html lang="{{ z_language|default:"en"|escape }}">
    <head>
        <meta charset="utf-8" />
        <title>Hackers &amp; Founders notifier</title>

        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
	    <meta name="author" content="Your name here" />
	    {% lib "bootstrap/css/bootstrap.css" %}
    </head>

    <body>
        <div class="container-fluid">
            <div class="content well" style="margin-top: 20px">
                {% block content %}
                {% endblock %}
            </div>
        </div>
    </body>

    {% include "_js_include.tpl" %}

    {% stream %}
    {% script %}

    {% block extra_scripts %}{% endblock %}

    {% lib
        "js/apps/zotonic-1.0.js"
        "js/apps/z.widgetmanager.js"
        "bootstrap/js/bootstrap.js"
    %}

</html>

