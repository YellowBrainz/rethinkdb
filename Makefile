NODENAME_RDB=rethinkdb
AUTHOR=tleijtens
NAME=rethinkdb
RDBDATA=rethinkdata
PWD=/dockerbackup
NETWORKID=42
SUBNET=10.0.42
VERSION=latest

start:	rethinkdb

stop:
	docker stop -t 0 $(NODENAME_RDB)

clean:
	docker rm -f $(NODENAME_RDB)

cleanrestart:	clean start

network:
	docker network create --subnet $(SUBNET).0/24 --gateway $(SUBNET).254 icec

datavolume:
	docker run -d -v $(RDBDATA):/data --name $(RDBDATA) --entrypoint /bin/echo debian:wheezy

backup:
	docker run --rm --volumes-from $(RDBDATA) -v $(PWD):/backup debian:wheezy bash -c "tar zcvf /backup/$(RDBDATA).tgz data"

restore:
	docker run --rm --volumes-from $(RDBDATA) -v $(PWD):/backup debian:wheezy bash -c "tar zxvf backup/$(RDBDATA).tgz"

rmnetwork:
	docker network rm icec

help:
	docker run -i $(NAME):$(VERSION) help

rethinkdb:
	docker run -d --net icec --ip $(SUBNET).12 -e SUBNET=$(SUBNET) --volumes-from=$(RDBDATA) -p 0.0.0.0:8080:8080 -p 0.0.0.0:28015:28015 -p 0.0.0.0:29015:29015 --name $(NODENAME_RDB) rethinkdb:latest rethinkdb --bind all

rmrethinkdb:
	docker rm -f $(NODENAME_RDB)

rmdatavolumes:
	docker rm -f $(RDBDATA)
	docker volume rm $(RDBDATA)

console:
	import rethinkdb as r
	conn = r.connect('localhost', 28015).repl()
	list(r.db('rethinkdb').table('server_status').run())
