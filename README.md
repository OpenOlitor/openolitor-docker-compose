# Docker Compose Configuration for OpenOlitor

[OpenOlitor](https://github.com/OpenOlitor/OpenOlitor) consists of multiple components and needs a DB server, an S3 compatible service and a document converter to provide its functionality.

This project makes it easy to:
 *  Run OpenOlitor on a local system to try it out and to develop frontend and/or backend features.
 *  Generate all configuration files based on a single [JSON-file](dev.json)
 *  Run OpenOlitor on a server/cloud infrastructure.

Here you find how to achieve this:

## Run on localhost

 1.  Make sure you have [docker](https://docs.docker.com/get-docker/) and [docker-compose](https://docs.docker.com/compose/install/) available on your host.
 2.  In a terminal window clone this repository: `git clone https://github.com/OpenOlitor/openolitor-docker-compose.git`
 3.  Change into the folder `cd openolitor-docker-compose`
 4.  Create all images: `docker-compose create db s3`
 5.  Bring up MariaDB and Minio (S3): `docker-compose start db s3` (wait a minute so the DB schema creation is done)
 6.  Bring up everything else: `docker-compose start`
 7.  Use your favorite browser to open [http://localhost:8080](http://localhost:8080)

Peace of cake.

This will use the default [docker-compose.yml](docker-compose.yml).

BTW: Sending emails is not enabled.

## Generate Configuration

You want to configure OpenOlitor so one or multiple groups/[CSA](https://en.wikipedia.org/wiki/Community-supported_agriculture)s may use OpenOlitor on your instance. This is easily possible using the provided generator. How to proceed:

 1.  Make sure you have python3 and the [Jinja2](https://pypi.org/project/Jinja2/) library available on your host.
 2.  Copy the environment template [dev.json](dev.json) to the name of your choice: 'cp dev.json [your-env].json'
 3.  Edit the file and add all needed
 4.  Call the generator `pyton3 generator.py [your-env]`
 5.  All configuration files are created, i.e. docker-compose.[your-env].yml
 6.  Use the new configuration by specifying the file using docker-compose: `docker-compose -f docker-compose.[your-env].yml start`

You may want to fork this repo as a private repository so you can safely check in your configuration and the generated files.

## Run on Server/Cloud-Environment

There is many different (cloud) environments docker compose may run on. Please share your experiences and knowledge if you use another environment. Currently we provide some information about the following:

 *  [Jelastic](docs/env-jelastic.md)
 *  [(Virtual) Server](docs/env-server.md)

Good practise is:

 *  Configure a firewall: Don't expose the ports of the database, S3 and such to the outside.

## Insights: Services

The following services are started:

 *  db: MariaDB (one instance for all with one database per configured CSA)
 *  s3: Minio (one instance for all with multiple buckets per configured CSA)
 *  client-kundenportal: OpenOlitor web UI for members
 *  client-admin: OpenOlitor web UI for administrators
 *  server: OpenOlitor Backend with all the magic (Scala application running on OpenJDK)
 *  pdf-tool: [Java OpenDocument Converter](https://github.com/EugenMayer/docker-image-jodconverter) providing a REST-API to transform ODF documents into PDF
 *  nginx: Webserver providing access to all services through one interface (Port 8080 on localhost; Port 80 for servers)

### Credits

Thanks to [Eike](https://github.com/yeoldegrove/) for his great [work](https://github.com/yeoldegrove/openolitor-docker) we have based this repo on.
