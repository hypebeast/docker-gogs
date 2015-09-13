all: help

help:
	@echo ""
	@echo "-- Help Menu"
	@echo ""
	@echo "   1. make build       - build the gogs image"
	@echo "   2. make quickstart  - start gogs with postgresql container"
	@echo "   3. make demo        - start gogs with sqlite database"
	@echo "   4. make stop        - stop gogs"
	@echo "   5. make logs        - view logs"
	@echo "   6. make purge       - stop and remove the container"
	@echo "   7. make shell       - run an interactive shell"
	@echo "   8. make debug       - connect to the running demo container and run an interactive shell"

build:
	@docker build --tag=${USER}/gogs .

quickstart:
	@echo "Starting gogs..."
	@docker run --name=gogs-demo -d -p 10030:3000 \
		-v /var/run/docker.sock:/run/docker.sock \
		-v $(shell which docker):/bin/docker \
		${USER}/gogs:latest >/dev/null
	@echo "Please be patient. This could take a while..."
	@echo "gogs will be available at http://localhost:/custom"
	@echo "Type 'make logs' for the logs"

demo:
	@echo "Starting gogs..."
	@docker run --name=gogs-demo -d -p 10030:3000 \
		${USER}/gogs:latest >/dev/null
	@echo "Please be patient. This could take a while..."
	@echo "gogs will be available at http://localhost:/custom"
	@echo "Type 'make logs' for the logs"

stop:
	@echo "Stopping gogs..."
	@docker stop gogs-demo >/dev/null

purge: stop
	@echo "Removing stopped container..."
	@docker rm gogs-demo >/dev/null

shell:
	@echo "Running interactive shell"
	@docker run -i -t ${USER}/gogs:latest /bin/bash

logs:
	@docker logs -f gogs-demo
