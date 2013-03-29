<p>Please enter your details to {% if new %}enable{% else %}update{% endif %} the @ouroffice notifier for this computer.</p>

{% wire type="submit" id=#create postback={update mac=mac} delegate=`myoffice` %}
<form id="{{ #create }}" action="postback" method="post" class="form-horizontal">

    <div class="control-group">
	    <label class="control-label" for="{{ #name }}">Your name</label>
        <div class="controls">
	        <input type="text" id="{{ #name }}" name="name" value="{{ user.name|escape }}" class="span4" />
	        {% validate id=#name name="name" type={presence} %}
        </div>
    </div>

    <div class="control-group">
	    <label class="control-label" for="{{ #name }}">Gender</label>
        <div class="controls">
	        <label class="radio inline">
                <input id="gender" type="radio" name="gender" value="F" {% if user.gender == 'f' %}checked{% endif %} />Female</input>
            </label>
	        <label class="radio inline">
                <input type="radio" name="gender" value="M" {% if user.gender == 'm' %}checked{% endif %} />Male</input>
            </label>
        </div>
    </div>

    <div class="control-group">
        <div class="controls">

            {% button class="btn" action={dialog_close} text="Cancel" tag="a" %}
            <button class="btn btn-primary" type="submit">{_ Submit _}</button>
        </div>
    </div>
</form>
