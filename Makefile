NGINX = nginx
MYSQL = mysql
PHP = php-7.2
TAG = alpine

HOME = $(CURDIR)
WWWROOT = /www

.PHONY: build run stop rm

default: build-development-environment

build-development-environment: \
	build \
	run \
	exec

build:
	docker build -t $(NGINX):$(TAG) ./nginx
	docker build -t $(MYSQL):$(TAG) ./mysql
	docker build -t $(PHP):$(TAG) ./php/7.2

pull:
    docker pull alpine:3.10

run:
    docker run --name=$(MYSQL) -d $(MYSQL):$(TAG) 
    docker run --name=$(PHP) -v $(HOME)/www\:$(WWWROOT) --link mysql:db -d $(PHP)\:$(TAG) 
    docker run --name=$(NGINX) --volumes-from $(PHP) --link $(PHP):php -v $(HOME)/nginx/default.conf\:/etc/nginx/conf.d/default.conf -p 80\:80 -d $(NGINX)\:$(TAG)

exec:
	docker exec $(NGINX) chown -R www-data:www-data $(WWWROOT)

stop:
	docker stop $(MYSQL) \
    docker stop $(PHP) \
    docker stop $(NGINX)

rm:
	docker rm mysql
	docker rm phpfpm
	docker rm nginx
