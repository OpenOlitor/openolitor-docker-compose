# Running OpenOlitor on a Root server

## Vorraussetzungen
Vorraussetzung ist ein laufender Root oder V-Server
* Hier sollten, müssen aber nicht, schon die grundlegenden Komponenten wie Firewall, Fail2ban und Co installiert sein.
* [Docker](https://docs.docker.com/get-docker/) und [docker-compose](https://docs.docker.com/compose/install/) müssen auf dem System vorhanden sein.
* Für das erstellen einer eigenen Config müssen python3 und die [Jinja2](https://pypi.org/project/Jinja2/) Bibliothek vorhanden sein.
* Ports 80 und 443 müssen in der Firewall offen sein. Andere Ports zur Datendank und zum S3 Speicher sollten aus Sicherheitsgründen nicht offen sein

## Installation


## Reverse-Proxy
* Port ändern (
