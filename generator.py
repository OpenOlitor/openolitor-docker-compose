#!/usr/bin/env python3

import json
import sys, getopt

from jinja2 import Environment, FileSystemLoader

def main(argv):
    try:
        opts, args = getopt.getopt(argv,"h:e:",["env="])
    except getopt.GetoptError:
        print ('generator.py -e [demo|test|testprod|prod|all]')
        sys.exit(2)
    if not opts:
        print ('generator.py -e [demo|test|testprod|prod|all]')
    else:
        for opt, arg in opts:
            if opt == '-h':
                print ('generator.py -e [test|testprod|prod|all]')
                sys.exit()
            elif opt in ("-e", "--environment"):
                if (arg == "all"):
                    createTemplates("test")
                    createTemplates("testprod")
                    createTemplates("prod")
                    createTemplates("demo")
                else:
                    createTemplates(arg)
            else:
                print ('generator.py -e [demo|test|testprod|prod|all]')


def createTemplates(environment):
    with open(environment + ".json") as environment_description:
        environmentDescription = json.load(environment_description)

    #create the docker compose file
    file_loader = FileSystemLoader('.')
    env = Environment(loader=file_loader)

    template = env.get_template('docker-compose.template.yml')

    output = template.render(s3 = environmentDescription["s3"], csas = environmentDescription["csas"], release_adminportal = environmentDescription["release_adminportal"], release_kundenportal = environmentDescription["release_kundenportal"], release_server = environmentDescription["release_server"], db = environmentDescription["db"], environment = environment)
    with open("docker-compose." + environment + ".yml", "w") as dockerComposeFile:
        dockerComposeFile.write(output)

    #create the db initialization file
    file_loader = FileSystemLoader('./config/db')
    env = Environment(loader=file_loader)
    template = env.get_template('db_schema.template.sql')

    output = template.render(csas = environmentDescription["csas"], db = environmentDescription["db"])
    with open("./config/db/db_schema." + environment + ".sql", "w") as dbInitialScript:
        dbInitialScript.write(output)

    #create the admin portal configuration files
    file_loader = FileSystemLoader('./config/client/admin')
    env = Environment(loader=file_loader)
    template = env.get_template('config.template.js')

    output = template.render(domain = environmentDescription["domain"])
    with open("./config/client/admin/config." + environment + ".js", "w") as dockerAdminPortalConfig:
        dockerAdminPortalConfig.write(output)

    #create the client portal configuration files
    file_loader = FileSystemLoader('./config/client/kundenportal')
    env = Environment(loader=file_loader)
    template = env.get_template('config.template.js')

    output = template.render(domain = environmentDescription["domain"])
    with open("./config/client/kundenportal/config." + environment + ".js", "w") as dockerKundenPortalConfig:
        dockerKundenPortalConfig.write(output)

    #create the server configuration file
    file_loader = FileSystemLoader('./config/server')
    env = Environment(loader=file_loader)
    template = env.get_template('openolitor-server.template.conf')

    output = template.render(csas = environmentDescription["csas"],s3 = environmentDescription["s3"])
    with open("./config/server/openolitor-server." + environment + ".conf", "w") as   openolitorServerConfigFile:
        openolitorServerConfigFile.write(output)

    #create the nginx configuration file
    file_loader = FileSystemLoader('./config/nginx')
    env = Environment(loader=file_loader)
    template = env.get_template('nginx.template.conf')

    output = template.render(csas = environmentDescription["csas"])
    with open("./config/nginx/nginx." + environment + ".conf", "w") as openolitorNginxConfigFile:
        openolitorNginxConfigFile.write(output)

if __name__ == "__main__":
   main(sys.argv[1:])
