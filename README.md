# Docker Compose (v2) Demo Environment for CloudBees Jenkins Platform (CJP)

# Included Services
* Nginx reverse proxy at http://cjp.local
* CloudBees Jenkins Operations Center (CJOC) 2.7.19.1 at http://cjp.local/cjoc
* CloudBees Jenkins Enterprise (CJE) 2.7.19.1 "test" at http://cjp.local/cje-test
* CloudBees Jenkins Enterprise (CJE) 2.7.19.1 "prod" at http://cjp.local/cje-prod
* Shared SSH Agent with Docker on Docker
* Shared JNLP Cloud with Java Build Tools (OpenJDK 8, Firefox, Selenium, etc.) and Docker on Docker

# Prerequisites

Built on [Docker for Mac Beta](https://blog.docker.com/2016/03/docker-for-mac-windows-beta/). Docker on Docker support may not work on other platforms.

1. Increase CPU/Memory limits in Docker preferences to as much as you can spare (e.g. CPU: 4, Memory: 6GB).

2. Open terminal and type:

        sudo vi /etc/hosts

    then add this entry:

        127.0.0.1 cjp.local

3. In ``docker-compose.yml``, under ``ssh-slave``, update ``volumes:`` to point to the maven cache (and/or other caches) on your host.

# How to run

Simply,

    docker-compose up

..from the project directory, and wait a little while :)

Important directories like Nginx logs, Jenkins home directories, etc. are volume mapped (persisted) to the working project directory.

# Post-Startup Tasks

## Connect Client Masters

1. Go to http://cjp.local/cjoc

2. Activate

3. Click Manage Jenkins > Configure System and set the Jenkins URL to http://cjp.local/cjoc (or just _save_ the config if it's already correct)

4. Add a client master item (cje-prod) with URL http://cjp.local/cje-prod

5. Add a client master item (cje-test) with URL  http://cjp.local/cje-test

## Connect SSH Shared Agent

1. `` exec `` into the CJOC container and generate a key pair:

        docker exec -it cjoc bash

        ssh-keygen

2. Stick with the defaults and choose a password (or leave blank)

3. Then copy your public and private keys to a text editor:

        cd /var/jenkins_home/.ssh

        cat id_rsa

        cat id_rsa.pub

4. In CJOC, click "Credentials" and add your SSH private key

5. In ``docker-compose.yml``, add your public key to the ``command:`` and restart the container:

        docker-compose restart ssh-slave

6. Create a Shared Slave item in CJOC (named e.g. ``shared-ssh-agent``), using the credentials above, host: ``ssh-slave``, and a Remote FS root of ``/home/jenkins``. Give it some labels, like ``shared``, ``ssh``, ``docker``, ``docker-cloud``

## Connect JNLP Shared Agent

1. Add a Shared Cloud item in CJOC (named e.g. `` shared-cloud ``)

2. In your `` docker-compose.yml `` file, under the `` jnlp-slave `` service, update `` command: ``  with the on-screen instructions. Give it some labels, like ``shared``, ``jnlp``, ``java-build-tools``, ``docker``, ``docker-cloud``

3. Start the JNLP agent (and watch it add itself to the shared-cloud):

        docker-compose restart jnlp-slave

*Note: The JNLP agent bombs on initial startup because the CJOC shared-cloud is not yet available - JNLP agents connect to the master, not the other way around. Thus, you must add it to the pool yourself (with a restart) after initializing the rest of the environment.*

### Docker on Docker

Supported by the following services:

* ``cje-test``
* ``ssh-slave``
* ``jnlp-slave``
* ``docker-service`` (over tcp)

When executing a ``docker`` command on these services, containers will spawn from the host docker engine (view with ``docker ps``). This magic is provided by Docker socket volume mapping, see ``-v /var/run/docker.sock:/var/run/docker.sock`` in ``docker-compose.yml``.

## Pro tips

* You can restart services with e.g.:

        docker-compose restart cje-test

    See `` docker-compose.yml `` for list of available services

* Use ⌃+c to stop the environment, or better, use:

      docker-compose down

* Open an interactive terminal on a container (service) with:

      docker exec -it <serviceName> bash

* Or run a command on a container immediately, e.g. to ping another container:

      docker exec -it <serviceName> ping cjp.proxy
