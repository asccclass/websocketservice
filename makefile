APP?=app
ImageName?=sherry/websocket
ContainerName?=websocket
PORT?=11030
DBServer?=MySQLx
poolPath?=filepool
MKFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
CURDIR := $(dir $(MKFILE))

init:
	GO111MODULE=on go mod download

build:
	clear
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 GO111MODULE=on go build -tags netgo \
	-o ${APP}
	chmod +x ${APP}

docker: build
	docker build -t ${ImageName} .
	rm -f ${APP}
	docker images

run: docker
	docker run -d --rm --name ${ContainerName} \
	-v /etc/localtime:/etc/localtime:ro \
	-v /etc/ssl/certs:/etc/ssl/certs \
	-v /etc/pki/ca-trust/extracted/pem:/etc/pki/ca-trust/extracted/pem \
	-v /etc/pki/ca-trust/extracted/openssl:/etc/pki/ca-trust/extracted/openssl \
	-v ${CURDIR}www:/app/www  \
	-v ${CURDIR}envfile:/app/envfile  \
	-p ${PORT}:80 \
	--env-file ${CURDIR}envfile \
	${ImageName}
	sh clean.sh
	clear
	make log	

rm:stop
	docker rm ${ContainerName}

stop:
	docker stop ${ContainerName}

log:
	docker logs -f -t --tail 20 ${ContainerName}

re: stop run

s:
	git push -u origin main
