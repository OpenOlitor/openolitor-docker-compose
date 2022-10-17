'use strict';

function getConfig() {
  var fullHostname = window.location.hostname;
  var instance = fullHostname.replace(".{{domain}}", "");

  var env = "{{env}}";
  {% for csa in csas %}
  {%- if csa.env -%}
  if(instance == "{{csa.name}}") {
    env = "{{csa.env}}";
  }
  {%- endif -%}
  {% endfor %}

  return {
    "API_URL": "https://" + fullHostname + "/api-" + instance + "/",
    "API_WS_URL": "https://" + fullHostname + "/api-" + instance + "/ws",
    "ENV": env,
    "version": "{{release_kundenportal}}",
    "sendStats": true
  };
}
