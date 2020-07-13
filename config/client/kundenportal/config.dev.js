'use strict';

function getConfig() {
  var fullHostname = window.location.hostname;
  var instance = fullHostname.replace(".openolitor.ch", "");

  var env = "dev";
  

  return {
    "API_URL": "https://" + fullHostname + "/api-" + instance + "/",
    "API_WS_URL": "https://" + fullHostname + "/api-" + instance + "/ws",
    "ENV": env,
    "version": "2.4.0",
    "AIRBREAK_API_KEY": "[errbit_api_key]",
    "AIRBREAK_URL": "https://errbit.host/",
    "sendStats": true
  };
}