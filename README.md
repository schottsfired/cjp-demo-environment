# Docker Compose Demo Environment for CloudBees Jenkins Platform

A great way to run CloudBees Jenkins on your laptop, with support for "Docker stuff"!

Feel free to clone/fork/extend this repo to meet your specific needs, and shoot me a PR if I missed anything!

My goal for this repo is to help people learn about CloudBees Jenkins and Docker while journeying through the README below.

## What does this include?
* Nginx reverse proxy at http://cjp.local (404 means it's running, home page is TODO)
* CloudBees Jenkins Operations Center (CJOC) at http://cjp.local/cjoc
* CloudBees Jenkins Enterprise (CJE) "prod" at http://cjp.local/cje-prod
* CloudBees Jenkins Enterprise (CJE) "test" at http://cjp.local/cje-test
* A Docker-enabled, shared SSH agent based on [jenkinsci/ssh-slave](https://hub.docker.com/r/jenkinsci/ssh-slave/)
* The ability to spawn Docker-enabled, shared JNLP agents based on [cloudbees/jnlp-slave-with-java-build-tools](https://hub.docker.com/r/cloudbees/jnlp-slave-with-java-build-tools/)

*NOTE: All services are intended to run on the same host in this example, but similar practices can be applied to e.g. Docker Swarm (multi host) setups.*

## Prerequisites

Go get [Docker for Mac](https://docs.docker.com/docker-for-mac/).

*NOTE: Docker on Docker support has not been tested on other platforms.*

1. Increase CPU/Memory limits in Docker preferences to as much as you can spare (e.g. CPU: 4, Memory: 6GB).

2. Open terminal and type:

        sudo vi /etc/hosts

    then add (or append) this entry:

        127.0.0.1 cjp.local

	so that your host file will look like the following example:
	
		##
		# Host Database
		#
		# localhost is used to configure the loopback interface
		# when the system is booting.  Do not change this entry.
		##
		127.0.0.1       localhost
		127.0.0.1       cjp.local
		255.255.255.255 broadcasthost
		::1             localhost	


3. Create a file called ``.env`` in the project directory (alongside ``docker-compose.yml``) and copy everything into it from the provided ``.env.sample``. Update the ``MAVEN_CACHE`` so that it's specific to your environment. If you don't have a Maven cache, or want to use additional/other caches, then update (or remove) the ``ssh-slave:`` ``volumes:`` in ``docker-compose.yml`` accordingly. For now this is the only change needed in ``.env``.

4. Create a Docker network by running this from the project directory:

        make network

## How to run (and restart after shutting down)

Simply type the following command

    docker-compose up -d

..from the project directory, and wait a while :)

You can view logs (and safely ctrl+c out of them) via:

    docker-compose logs -t -f

Important directories like JENKINS_HOME(s), Nginx logs, etc. are volume mapped (persisted) to the working project directory. Treat JENKINS_HOME directories (under ``./data/...``) with care, and consider regular backups.

## Post-Startup Checklist

### Connect Client Masters (one time)

1. Activate CJOC at http://cjp.local/cjoc using the recommended settings

2. Follow the same process for http://cjp.local/cje-prod and http://cjp.local/cje-test, again with recommended settings

3. In CJOC, create Client Master items for ``cje-prod`` and ``cje-test``, and use the URLs from step 2 to make the connection

### Connect ssh-slave as a Shared Slave (one time)

1. `` exec `` into the CJOC container and generate a key pair:

        docker exec -it cjoc bash

        ssh-keygen

2. Stick with the defaults and choose a password (or leave blank).

3. Copy your private key to a text editor:

        cat /var/jenkins_home/.ssh/id_rsa

4. In CJOC, click "Credentials", "System", "Global credentials (unrestricted)", "Add Credentials", select ``SSH Username with private key``. Enter ``jenkins`` as the username and select ``Enter Directly`` for the Private key option.

5. In ``.env``, replace ``SSH_SLAVE_COMMAND`` with the public key that was just generated, save, and refresh the environment with ``docker-compose up``

6. Create a Shared Slave item in CJOC (named e.g. ``shared-ssh-agent``), using the credentials above, host: ``ssh-slave``, and a Remote FS root of ``/home/jenkins``. Give it some labels, like ``shared``, ``ssh``, ``docker``, ``docker-cloud``.

### Add JNLP Agent(s) to a Shared Cloud (config once, then repeat step 4)

1. Add a Shared Cloud item in CJOC (named e.g. `` shared-cloud ``). Remote FS root is ``/home/jenkins``. Give it some labels, like ``shared``, ``jnlp``, ``java-build-tools``, ``docker``, ``docker-cloud`` and click Save. You should now be taken to a screen that displays the slave command to run.

2. In ``.env``, replace ``SHARED_CLOUD_NAME`` if needed, and replace ``JNLP_SLAVE_COMMAND`` with the ``-secret`` you find the Jenkins UI, then save your changes.

3. Build the JNLP agent:

        make build-jnlp-slave

3. Launch a JNLP agent into the Shared Cloud, repeatedly if desired:

        make jnlp-slave

4. Finally, destroy all JNLP slaves:

        make destroy-jnlp

## What Next?

Automate all the things!

### Consider the following plugins

* [Mock Security Realm](https://wiki.jenkins-ci.org/display/JENKINS/Mock+Security+Realm+Plugin)
* [CloudBees Docker Build and Publish](https://wiki.jenkins-ci.org/display/JENKINS/CloudBees+Docker+Build+and+Publish+plugin)
* [CloudBees Docker Custom Build Environment](https://wiki.jenkins-ci.org/display/JENKINS/CloudBees+Docker+Custom+Build+Environment+Plugin)
* [CloudBees Docker Pipeline](https://wiki.jenkins-ci.org/display/JENKINS/CloudBees+Docker+Pipeline+Plugin)
* [Docker Slaves Plugin](https://wiki.jenkins-ci.org/display/JENKINS/Docker+Slaves+Plugin) (use in tandem with ``docker-service`` in ``docker-compose.yml``)

## Miscellaneous

### Upgrades

Please refer to the [Releases Page](https://github.com/schottsfired/cjp-demo-environment/releases) for upgrade instructions.

### Docker on Docker (a.k.a "Docker inception")

Is supported by the following services:

* ``cje-test``
* ``ssh-slave``
* ``jnlp-slave``
* ``docker-service`` (tcp://docker-service:2375)

When executing a ``docker`` command from within these containers, the Docker client installed inside the container communicates with the  Docker server outside the container. This magic is provided by Docker socket volume mapping; see ``-v /var/run/docker.sock:/var/run/docker.sock`` in ``docker-compose.yml``. For more information, read [this famous blog post](https://jpetazzo.github.io/2015/09/03/do-not-use-docker-in-docker-for-ci/).

### Pro tips
* See what's running:

        docker ps

* Shutdown command(s):

        docker-compose down

        make destroy-jnlp

* Clean Docker after shutting down:

        make clean

* Tail the logs for a running container:

        docker logs -f $CONTAINER_NAME_OR_ID

* Open an interactive terminal on a running container:

        docker exec -it $CONTAINER_NAME_OR_ID sh

* Run a command within a container immediately, e.g. to test networking

        docker exec -it $CONTAINER_NAME_OR_ID ping cjp.proxy
