<%inherit file="project.view.mako" />
<form method="post" action="${node_to_use.url}/remove">
    <button type="submit" class="btn primary">Delete this component and all non-project components</button>
</form>

<div mod-meta='{"tpl":"render_keys.html", "uri":"/api/v1${node_to_use.url}/keys/", "replace": true, "kwargs" : {"route": "/api/v1${node_to_use.url}/"}}'></div>