'use strict';

function getConfig() {
  var fullHostname = window.location.hostname;
  var instance = fullHostname.replace(".openolitor.ch", "");

  var env = "dev";
  

  return {
    "API_URL": "https://" + fullHostname + "/api-" + instance + "/",
    "API_WS_URL": "https://" + fullHostname + "/api-" + instance + "/ws",
    "ENV": env,
    "version": "latest",
    "EMAIL_TO_ADDRESS": "info@tegonal.com",
    "sendStats": true
  };
}