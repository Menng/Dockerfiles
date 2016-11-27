NGINX = nginx
MYSQL = mysql
PHP = php
VERSION = latest

REPO = debian
INSTANCE = default

HOME = /home/m/workspace/Dockerfiles
WWWROOT = /usr/share/nginx/html/

.PHONY: build push shell run start stop rm release

default: build-development-environment

build-development-environment: \
	build \
	run \
	exec

build:
	docker build -t $(REPO)/$(NGINX):$(VERSION) ./nginx
	docker build -t $(REPO)/$(MYSQL):$(VERSION) ./mysql
	docker build -t $(REPO)/$(PHP):$(VERSION) ./php/7.0

push:
	docker push $(NS)/$(REPO):$(VERSION)

shell:
	docker run --rm --name $(NAME)-$(INSTANCE) -i -t $(PORTS) $(VOLUMES) $(ENV) $(NS)/$(REPO):$(VERSION) /bin/bash

pull:
	docker pull busybox:latest

run:
	#docker run --name=mysql_data -v $(HOME)Docker -d busybox
	#docker run --name=wwwroot -v $(HOME)Docker/www:$(WWWROOT) -d busybox
	docker run --name=mysql -d $(REPO)/mysql
	docker run --name=phpfpm -v $(HOME)/www:$(WWWROOT) --link mysql:db -d $(REPO)/php
	docker run --name=nginx --volumes-from phpfpm --link phpfpm:php -v $(HOME)/nginx/default.conf:/etc/nginx/conf.d/default.conf -p 80:80 -d $(REPO)/nginx

start:
	docker run -d --name $(NAME)-$(INSTANCE) $(PORTS) $(VOLUMES) $(ENV) $(NS)/$(REPO):$(VERSION)

exec:
	docker exec $(NGINX) chown -R www-data:www-data $(WWWROOT)

stop:
	docker stop $(NAME)-$(INSTANCE)

rm:
	docker rm $(NAME)-$(INSTANCE)

release: build
	make push -e VERSION=$(VERSION)
