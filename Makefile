PROJECTS=gerrit-master gerrit-master-nginx gerrit-slave gerrit-slave-nginx gerrit-slave-httpd gerrit-haproxy

start: build
	docker-compose up -d

stop:
	docker-compose down

status:
	docker ps

build: 
	for project in $(PROJECTS); do bash -c "cd $$project && docker build -t $$project ."; done	

restart: stop start

.PHONY: build stop status
