all: help

help:
	@echo ""
	@echo "-- Help Menu"
	@echo ""
	@echo "   1. make build       - build the gogs image"
	@echo "   2. make quickstart  - start gogs"
	@echo "   3. make stop        - stop gogs"
	@echo "   4. make logs        - view logs"
	@echo "   5. make purge       - stop and remove the container"

build:
	@docker build --tag=${USER}/gogs .

quickstart:
	@echo "Starting gogs..."
	@docker run --name=gogs-demo -d -p 3000:3000 \
		-v /var/run/docker.sock:/run/docker.sock \
		-v $(shell which docker):/bin/docker \
		${USER}/gogs:latest >/dev/null
	@echo "Please be patient. This could take a while..."
	@echo "gogs will be available at http://localhost:3000"
	@echo "Type 'make logs' for the logs"

stop:
	@echo "Stopping gogs..."
	@docker stop gogs-demo >/dev/null

purge: stop
	@echo "Removing stopped container..."
	@docker rm gogs-demo >/dev/null

logs:
	@docker logs -f gogs-demo
