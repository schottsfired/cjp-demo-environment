# Docker Compose Demo Environment for CloudBees Jenkins Platform

A great way to run CloudBees Jenkins on your laptop, with support for "Docker stuff"!

Feel free to clone/fork and extend this repo to meet your specific needs, and shoot me a PR if I missed anything!

My goal for this repo is to help people learn about CloudBees Jenkins and Docker while journeying through the README below.

*DISCLAIMER: Not officially suppported by CloudBees. A very cool, pre-configured Docker trial is available [here](https://www.cloudbees.com/get-started) on the CloudBees website.*

## What does this include?
* Nginx reverse proxy at http://cjp.local
* CloudBees Jenkins Operations Center (CJOC) at http://cjp.local/cjoc
* CloudBees Jenkins Enterprise (CJE) "prod" at http://cjp.local/cje-prod
* CloudBees Jenkins Enterprise (CJE) "test" at http://cjp.local/cje-test
* A *shared* SSH agent based on [jenkinsci/ssh-slave](https://hub.docker.com/r/jenkinsci/ssh-slave/)
* A *shared* Cloud with one JNLP agent based on [cloudbees/jnlp-slave-with-java-build-tools](https://hub.docker.com/r/cloudbees/jnlp-slave-with-java-build-tools/)
* Support for Docker on Docker

*NOTE: All services are intended to run on the same host in this example.*

## Prerequisites

Built on [Docker for Mac Beta](https://blog.docker.com/2016/03/docker-for-mac-windows-beta/).

*NOTE: Docker on Docker support may not work on other platforms.*

1. Increase CPU/Memory limits in Docker preferences to as much as you can spare (e.g. CPU: 4, Memory: 6GB).

2. Open terminal and type:

        sudo vi /etc/hosts

    then add (or append) this entry:

        127.0.0.1 cjp.local

3. Create a file called ``.env`` in the project directory (alongside ``docker-compose.yml``) and copy everything into it from the provided ``.env.sample``. Update the ``MAVEN_CACHE`` so that it's specific to your environment. If you don't have a Maven cache, or want to use additional/other caches, then update the ``ssh-slave:`` ``volumes:`` in ``docker-compose.yml`` accordingly. For now this is the only change needed in ``.env``.

## How to run

Simply,

    docker-compose up

..from the project directory, and wait a little while :)

Important directories like JENKINS_HOME(s), Nginx logs, etc. are volume mapped (persisted) to the working project directory. Treat JENKINS_HOME directories with care, and consider backups.

## Post-Startup Tasks

### Connect Client Masters

1. Go to http://cjp.local/cjoc

2. Activate

3. Click Manage Jenkins > Configure System and set the Jenkins URL to http://cjp.local/cjoc (or just _save_ if it's already correct)

4. Add a Client Master item named e.g. ``cje-prod`` with URL http://cjp.local/cje-prod.

5. Add a Client Master item named e.g. ``cje-test`` with URL  http://cjp.local/cje-test.

### Connect SSH Shared Agent

1. `` exec `` into the CJOC container and generate a key pair:

        docker exec -it cjoc bash

        ssh-keygen

2. Stick with the defaults and choose a password (or leave blank).

3. Copy your public key to a text editor:

        cd /var/jenkins_home/.ssh

        cat id_rsa.pub

4. In CJOC, click "Credentials", "System", "Global credentials (unrestricted)", "Add Credentials", select ``SSH Username with private key``. Enter ``jenkins`` as the username and select ``From the Jenkins master ~/.ssh`` for the Private key option.

5. In ``.env``, replace ``SSH_SLAVE_COMMAND`` with the public key that was just generated, save, and restart the container:

        docker-compose restart ssh-slave

6. Create a Shared Slave item in CJOC (named e.g. ``shared-ssh-agent``), using the credentials above, host: ``ssh-slave``, and a Remote FS root of ``/home/jenkins``. Give it some labels, like ``shared``, ``ssh``, ``docker``, ``docker-cloud``.

### Connect JNLP Shared Agent

1. Add a Shared Cloud item in CJOC (named e.g. `` shared-cloud ``). Remote FS root is ``/home/jenkins``. Give it some labels, like ``shared``, ``jnlp``, ``java-build-tools``, ``docker``, ``docker-cloud`` and click Save. You should now be taken to a screen that displays the slave command to run.

2. In ``.env``, replace ``JNLP_SLAVE_COMMAND`` with the ``-secret`` you see in the Jenkins UI, then save.

3. Start the JNLP agent (and watch it add itself to the shared-cloud):

        docker-compose restart jnlp-slave

*Note: The JNLP agent bombs on initial startup because the CJOC shared-cloud is not available and ready to accept clients - remember: JNLP agents connect to the master, not the other way around. Add it to the shared-cloud pool (via ``restart``) after CJOC is up and running.*

## What Next?

Automate all the things!

### Consider the following plugins

* [Mock Security Realm](https://wiki.jenkins-ci.org/display/JENKINS/Mock+Security+Realm+Plugin)
* [CloudBees Docker Build and Publish](https://wiki.jenkins-ci.org/display/JENKINS/CloudBees+Docker+Build+and+Publish+plugin)
* [CloudBees Docker Custom Build Environment](https://wiki.jenkins-ci.org/display/JENKINS/CloudBees+Docker+Custom+Build+Environment+Plugin)
* [CloudBees Docker Pipeline](https://wiki.jenkins-ci.org/display/JENKINS/CloudBees+Docker+Pipeline+Plugin)
* [Docker Slaves Plugin](https://wiki.jenkins-ci.org/display/JENKINS/Docker+Slaves+Plugin) (use in tandem with ``docker-service``)

## Miscellaneous

### Docker on Docker (a.k.a "Docker inception")

Is supported by the following services:

* ``cje-test``
* ``ssh-slave``
* ``jnlp-slave``
* ``docker-service`` (tcp://docker-service:2375)

When executing a ``docker`` command from within these containers, the Docker client installed inside the container communicates with the  Docker server outside the container. This magic is provided by Docker socket volume mapping; see ``-v /var/run/docker.sock:/var/run/docker.sock`` in ``docker-compose.yml``. For more information, read [this famous blog post](https://jpetazzo.github.io/2015/09/03/do-not-use-docker-in-docker-for-ci/).

### Pro tips

* Use ``⌃ + C`` to stop the environment, or better, use:

        docker-compose down

* Clean your environment often (free disk space, fix "strange" issues) with:

        ./docker-clean.sh

* Open an interactive terminal on a container (service) with:

        docker exec -it <containerName/serviceName> bash

* Or run a command within a container immediately, e.g. to ping another container (thank you Docker 1.12 :)

        docker exec -it <containerName/serviceName> ping cjp.proxy
