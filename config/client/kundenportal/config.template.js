'use strict';

function getConfig() {
  var fullHostname = window.location.hostname;
  var instance = fullHostname.replace(".{{domain}}", "");

  return {
    "API_URL": "https://" + fullHostname + "/api-" + instance + "/",
    "API_WS_URL": "https://" + fullHostname + "/api-" + instance + "/ws",
    "ENV": "dev",
    "version": "2.4.0",
    "AIRBREAK_API_KEY": "48f4d0be704fafd7ed7b4fdf2d2119d9",
    "AIRBREAK_URL": "https://errbit.tegonal.com/",
    "sendStats": true
  };
}
