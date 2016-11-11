NODENAME_RDB=rethinkdb
AUTHOR=tleijtens
NAME=rethinkdb
RDBDATA=rethinkdbdata
PWD=/dockerbackup
NETWORKID=42
SUBNET=10.0.42
VERSION=latest

start:	rethinkdb

stop:
	docker stop $(NODENAME_RDB)

clean:
	docker rm -f $(NODENAME_RDB)

cleanrestart:	clean start

network:
	docker network create --subnet $(SUBNET).0/24 --gateway $(SUBNET).254 icec

datavolumes:
	docker run -d -v $(RDBDATA):/data --name $(RDBDATADB) --entrypoint /bin/echo debian:wheezy

backup:
	docker run --rm --volumes-from $(RDBDATADB) -v $(PWD):/backup debian:wheezy bash -c "tar zcvf /backup/$(RDBDATADB).tgz data"

restore:
	docker run --rm --volumes-from $(RDBDATADB) -v $(PWD):/backup debian:wheezy bash -c "tar zxvf backup/$(RDBDATADB).tgz"

rmnetwork:
	docker network rm icec

help:
	docker run -i $(NAME):$(VERSION) help

rethinkdb:
	docker run -d --net icec --ip $(SUBNET).12 -e SUBNET=$(SUBNET) --volumes-from=$(RDBDATA) -p 8080:8080 --name $(NODENAME_RDB) rethinkdb:latest rethinkdb

rmrethinkdb:
	docker rm -f $(NODENAME_RDB)

rmdatavolumes:
	docker rm -f $(RDBDATA)
	docker volume rm $(RDBDATA)
