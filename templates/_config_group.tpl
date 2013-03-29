<div class="control-group">
    <h3>{{ caption }}</h3>
    {% if expl %}
        <p>{{ expl }}</p>
    {% endif %}
</div>

{% for k,title in fields %}
    <div class="control-group">
	    <label class="control-label" for="{{ #id.k }}">{{ title }}</label>
        <div class="controls">
	        <input type="text" id="{{ #id.k }}" name="{{ k }}" value="{{ m.myoffice.config[k]|escape }}" class="span4" />
	        {% validate id=#id.k name=k type={presence} %}
        </div>
    </div>
{% endfor %}
