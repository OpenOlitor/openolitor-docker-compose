# OpenOlitor auf einem eigenen root oder V-server
English version below
## Vorraussetzungen
Vorraussetzung ist ein laufender Root oder V-Server
* Hier sollten, müssen aber nicht, schon die grundlegenden Komponenten wie Firewall, Fail2ban und Co installiert sein.
* [Docker](https://docs.docker.com/get-docker/), [docker-compose](https://docs.docker.com/compose/install/) und git müssen auf dem System vorhanden sein.
* Für das erstellen einer eigenen Config müssen python3 und die [Jinja2](https://pypi.org/project/Jinja2/) Bibliothek vorhanden sein.
* Ports 80 und 443 müssen in der Firewall offen sein. Andere Ports zur Datendank und zum S3 Speicher sollten aus Sicherheitsgründen nicht offen sein.
* Eine eingerichtete Subdomain z. B. solawi-blubb.beispiel.de
* Ein erstelltes Zertifikat für die Subdomain

## Installation
 1.  Am Server per ssh anmelden.
 2.  Nun muss das git Repo mit folgendem Befehl geklont werden: `git clone https://github.com/OpenOlitor/openolitor-docker-compose.git`
 3.  In das Verzeichnis wechseln `cd openolitor-docker-compose`
 4.  Jetzt kann das environment dev template kopiert werden [dev.json](dev.json) kopiert werden und mit dem Namen `prod` versehen werden: `cp dev.json [ENV].json.[]`
 5.  Jetzt kann die [ENV].json nach belieben bearbeitet werden.
     - hier können z.B. die release_Variablen auf "latest" gesetzt werden, wenn man immer die aktuelle letzte Version haben möchte.
     - Der Domainname sollte eingepasst werden z. B. beispiel.de
     - Die Passwörter sollten alle geändert werden.
     - Wichtig ist, dass man den selben Namen unter csas verwendet, wie auch die Subdomain heißt! Hier z. B. solawi-blubb
     - weiter unten können die  smtp-Daten für den E-Mail-Versand eingegeben werden.
       - Bei endpoint wird der smtp-Server eingetragen.
 6.  Hat man alles angepasst, kann man mit `python3 generator.py -e [ENV]` die Konfigurations-Dateien erstellen
 7.  Alle Konfigurations-Dateien wurden erstellt wie z. B. docker-compose.[ENV].yml
 8.  Jetzt kann man die Container starten. Für den ersten Start sollte erstmal die Datenbank und der S3 Speicher alleine gestartet werden `docker-compose -f docker-compose.[ENV].yml up -d db s3`
 9.  Einen Monment warten bis alles erstellt worden ist.
 10.  Jetzt kann man die restlichen Container starten: `docker-compose -f docker-compose.[ENV].yml up -d`
 11.  Wenn alles gestartet ist, sollte OpenOlitor über solawi-blubb.beispiel.de erreichbar sein.

## Eigener nginx
Hat man auf dem Server eventuell schon einen nginx am laufen, kann man diesen auch nutzen. Dazu muss man den Port von dem nginx Docker Container ändern, damit kein Konflikt entsteht:
* Hierzu die Datei `docker-compose.[ENV].yml` öffnen, den Bereich vom nginx Container suchen und hier die Ports von `80:9000` auf z. B. `8090:9000` ändern.
   - Hier ist zu beachten, dass der Port überschrieben wird, wenn man die Konfiguration mit dem python skript neu erstellt. Möchte man das nicht, muss der Port in der `docker-compose.template.yml` Datei geändert werden.
   - Man kann `cert-bot` nutzen um sich ein Zertifikat bei let's encrypt erstellen zu lassen. Certbot ergänzt dann auch die Konfig für nginx.

Hier eine Beispiel-Konfiguration:

```nginx 
server {
  server_name solawi-blubb.beispiel.de;

  listen [::]:443 ssl;
  listen 443 ssl;

  ssl_certificate /path/to/fullchain.pem;
  ssl_certificate_key /path/to/privkey.pem;
  include /path/to/options-ssl-nginx.conf;
  ssl_dhparam /path/to/ssl-dhparams.pem;

  location /lool/ {
    proxy_pass http://127.0.0.1:8080/lool/;
    proxy_connect_timeout       300s;
    proxy_send_timeout          600s;
    proxy_read_timeout          1800s;
    send_timeout                600s;
    }

  location /admin/ {
    add_header 'Access-Control-Allow-Credentials' 'true';
    proxy_pass http://127.0.0.1:9100/;
    proxy_connect_timeout       300s;
    proxy_send_timeout          300s;
    proxy_read_timeout          300s;
    send_timeout                300s;
    }

  location / {
    add_header 'Access-Control-Allow-Credentials' 'true';
    proxy_pass http://127.0.0.1:9110/;
    proxy_connect_timeout       300s;
    proxy_send_timeout          300s;
    proxy_read_timeout          300s;
    send_timeout                300s;
    }

  location ~* ^/api-.*/ws$ {
  rewrite ^/api-(.*/ws)$ /$1 break;
  proxy_pass http://127.0.0.1:9003;
  proxy_http_version 1.1;
  proxy_set_header Upgrade $http_upgrade;
  proxy_set_header Connection "upgrade";
  proxy_connect_timeout       3600s;
  proxy_send_timeout          600s;
  proxy_read_timeout          3600s;
  send_timeout                600s;
  }

  location ~* ^/api-.* {
    set $cors '';
    if ($http_origin ~ '^https?://(localhost:9000|localhost:8080|localhost:8081|.*\.openolitor\.ch)') {
      set $cors 'true';
      }

  if ($cors = 'true') {
    add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS' always;
    add_header 'Access-Control-Allow-Headers' 'Accept,Authorization,Cache-Control,Content-Type,DNT,If-Modified-Since,Keep-Alive,Origin,User-Agent,X-Requested-With' always;
    }
  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  add_header 'Access-Control-Allow-Credentials' 'true' always;
  rewrite ^/api-(.*)$ /$1 break;
  proxy_pass http://127.0.0.1:9003;
  proxy_connect_timeout       300s;
  proxy_send_timeout          300s;
  proxy_read_timeout          300s;
  send_timeout                300s;
  }

  location /smtp-proxy/ {
    auth_basic "Administrator's Area";
    auth_basic_user_file htpasswd;
    add_header 'Access-Control-Allow-Credentials' 'true';
    proxy_pass http://127.0.0.1:8025/;
    proxy_connect_timeout       300s;
    proxy_send_timeout          300s;
    proxy_read_timeout          300s;
    send_timeout                300s;
    }

  location /smtp-proxy/api/v2/websocket {
    proxy_pass http://127.0.0.1:8025/api/v2/websocket;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_connect_timeout       3600s;
    proxy_send_timeout          600s;
    proxy_read_timeout          3600s;
    send_timeout                600s;
    }

}

server {
if ($host = solawi-blubb.beispiel.de) {
return 301 https://$host$request_uri;
}

listen 80;
listen [::]:80;
server_name solawi-blubb.beispiel.de;
return 404;

}
```

# ENGLISH Version
Translated with www.DeepL.com
## Requirements
Prerequisite is a running root or V-Server.
* Here, the basic components such as firewall, fail2ban and co should, but do not have to, already be installed.
* [Docker](https://docs.docker.com/get-docker/), [docker-compose](https://docs.docker.com/compose/install/) and git must be present on the system.
* Python3 and the [Jinja2](https://pypi.org/project/Jinja2/) library must be present to create a custom config.
* Ports 80 and 443 must be open in the firewall. Other ports to database and S3 storage should not be open for security reasons.
* An established subdomain e.g. solawi-blubb.example.com.
* A created certificate for the subdomain

## Installation
 1. log in to the server via ssh.
 2. now you have to clone the git repo with the following command: `git clone https://github.com/OpenOlitor/openolitor-docker-compose.git`.
 3. change into the directory `cd openolitor-docker-compose`.
 4. now the environment dev template can be copied [dev.json](dev.json) and named `prod`: `cp dev.json [ENV].json.[]`
 5. now you can edit the [ENV].json as you like.
     - here you can e.g. set the release_variables to "latest", if you always want to have the latest version.
     - The domain name should be fitted e.g. example.de
     - The passwords should all be changed.
     - It is important to use the same name under csas as the subdomain is called! Here e.g. solawi-blubb
     - further down you can enter the smtp data for sending e-mails.
       - At endpoint the smtp server is entered.
 6. if you have adjusted everything you can create the configuration files with `python3 generator.py -e [ENV]`.
 7. all configuration files have been created like docker-compose.[ENV].yml
 8. now you can start the containers. For the first start you should start the database and the S3 storage alone `docker-compose -f docker-compose.[ENV].yml up -d db s3`.
 9. wait one month until everything has been created.
 10. now you can start the remaining containers: `docker-compose -f docker-compose.[ENV].yml up -d`.
 11. when everything is started, OpenOlitor should be accessible via solawi-blubb.example.com.

## Own nginx
If you already have a nginx running on your server you can use it, you have to change the port of the nginx docker container to avoid a conflict:
* Open the file `docker-compose.[ENV].yml`, search the area of the nginx container and change the port from `80:9000` to e.g. `8090:9000`.
   - Please note that the port will be overwritten if you rebuild the configuration with the python script. If you don't want this, you have to change the port in the `docker-compose.template.yml` file.
   - You can use `cert-bot` to get a certificate from let's encrypt. Certbot then also completes the config for nginx.

Here is an example configuration:

```nginx
server {
  server_name solawi-blubb.beispiel.de;

  listen [::]:443 ssl;
  listen 443 ssl;

  ssl_certificate /path/to/fullchain.pem;
  ssl_certificate_key /path/to/privkey.pem;
  include /path/to/options-ssl-nginx.conf;
  ssl_dhparam /path/to/ssl-dhparams.pem;

  location /lool/ {
    proxy_pass http://127.0.0.1:8080/lool/;
    proxy_connect_timeout       300s;
    proxy_send_timeout          600s;
    proxy_read_timeout          1800s;
    send_timeout                600s;
    }

  location /admin/ {
    add_header 'Access-Control-Allow-Credentials' 'true';
    proxy_pass http://127.0.0.1:9100/;
    proxy_connect_timeout       300s;
    proxy_send_timeout          300s;
    proxy_read_timeout          300s;
    send_timeout                300s;
    }

  location / {
    add_header 'Access-Control-Allow-Credentials' 'true';
    proxy_pass http://127.0.0.1:9110/;
    proxy_connect_timeout       300s;
    proxy_send_timeout          300s;
    proxy_read_timeout          300s;
    send_timeout                300s;
    }

  location ~* ^/api-.*/ws$ {
  rewrite ^/api-(.*/ws)$ /$1 break;
  proxy_pass http://127.0.0.1:9003;
  proxy_http_version 1.1;
  proxy_set_header Upgrade $http_upgrade;
  proxy_set_header Connection "upgrade";
  proxy_connect_timeout       3600s;
  proxy_send_timeout          600s;
  proxy_read_timeout          3600s;
  send_timeout                600s;
  }

  location ~* ^/api-.* {
    set $cors '';
    if ($http_origin ~ '^https?://(localhost:9000|localhost:8080|localhost:8081|.*\.openolitor\.ch)') {
      set $cors 'true';
      }

  if ($cors = 'true') {
    add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS' always;
    add_header 'Access-Control-Allow-Headers' 'Accept,Authorization,Cache-Control,Content-Type,DNT,If-Modified-Since,Keep-Alive,Origin,User-Agent,X-Requested-With' always;
    }
  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  add_header 'Access-Control-Allow-Credentials' 'true' always;
  rewrite ^/api-(.*)$ /$1 break;
  proxy_pass http://127.0.0.1:9003;
  proxy_connect_timeout       300s;
  proxy_send_timeout          300s;
  proxy_read_timeout          300s;
  send_timeout                300s;
  }

  location /smtp-proxy/ {
    auth_basic "Administrator's Area";
    auth_basic_user_file htpasswd;
    add_header 'Access-Control-Allow-Credentials' 'true';
    proxy_pass http://127.0.0.1:8025/;
    proxy_connect_timeout       300s;
    proxy_send_timeout          300s;
    proxy_read_timeout          300s;
    send_timeout                300s;
    }

  location /smtp-proxy/api/v2/websocket {
    proxy_pass http://127.0.0.1:8025/api/v2/websocket;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_connect_timeout       3600s;
    proxy_send_timeout          600s;
    proxy_read_timeout          3600s;
    send_timeout                600s;
    }

}

server {
if ($host = solawi-blubb.beispiel.de) {
return 301 https://$host$request_uri;
}

listen 80;
listen [::]:80;
server_name solawi-blubb.beispiel.de;
return 404;

}
```
