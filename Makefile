include .env

default: clean

network:
	docker network create cjp-demo-environment || true

build-jnlp-agent:
	docker build --rm \
	-f docker/Dockerfile.jnlp-agent \
	-t jnlp-agent ./docker

jnlp-agent:
	docker run -d \
	--network=cjp-demo-environment \
	-e "JENKINS_URL=http://cjp.local/cjoc" \
	-v $(MAVEN_CACHE) \
	-v /var/run/docker.sock:/var/run/docker.sock \
	jnlp-agent \
	$(JNLP_AGENT_COMMAND) \
	$(SHARED_CLOUD_NAME)

destroy-jnlp:
	docker rm $$(docker stop $$(docker ps -a -q --filter="ancestor=jnlp-agent"))
	
build-swarm-agent:
	docker build --rm \
	-f docker/Dockerfile.swarm-agent \
	-t swarm-agent .
	
swarm-agent:
	docker run -d \
	--network=cjp-demo-environment \
	swarm-agent \
	java -jar swarm-client-3.3.jar \
	-master $(SWARM_MASTER) \
	-username $(SWARM_USER) \
	-password $(SWARM_PASS)

destroy-swarm-agents:
	docker rm $$(docker stop $$(docker ps -a -q --filter="ancestor=swarm-agent"))

clean:
	./docker-clean.sh
