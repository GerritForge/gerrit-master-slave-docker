PROJECTS=gerrit-master gerrit-slave

build: 
	for project in $(PROJECTS); do bash -c "cd $$project && docker build -t $$project ."; done	
