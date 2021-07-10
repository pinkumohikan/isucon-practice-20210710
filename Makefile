.PHONY: gogo all app bench slow-log kataribe
all: gogo

app:
	make -C webapp/go build

gogo:
	sudo systemctl stop h2o.service
	sudo systemctl stop torb.go.service
	ssh centos@172.31.25.227  "sudo systemctl stop mysqld"
	sudo truncate --size 0 /var/log/h2o/access.log
	sudo truncate --size 0 /var/log/h2o/error.log
	ssh centos@172.31.25.227  "sudo truncate --size 0 /var/lib/mysql/mysql-slow.log"
	sudo truncate --size 0 /var/log/mariadb/mariadb.log
	$(MAKE) app
	scp -C -i ~/.ssh/id_rsa webapp/go/torb centos@172.31.17.234:~/
	ssh centos@172.31.17.234 "sudo cp torb /home/isucon/torb/webapp/go/"
	ssh centos@172.31.25.227 "sudo systemctl start mysqld"
	sudo systemctl start torb.go.service
	ssh centos@172.31.17.234 "sudo systemctl start torb.go.service"
	sudo systemctl start h2o
	sleep 2
	$(MAKE) bench

bench:
	ssh -i ~/.ssh/id_rsa centos@54.168.238.28 "cd /home/centos/torb/bench && ./bin/bench -remotes=35.74.254.73 -output result.json"
	ssh -i ~/.ssh/id_rsa centos@54.168.238.28 "cd /home/centos/torb/bench && jq . < result.json"

slow-log:
	ssh centos@172.31.25.227 "sudo cp /var/lib/mysql/mysql-slow.log /tmp/mysql-slow.log"
	ssh centos@172.31.25.227 "sudo chmod 777 /tmp/mysql-slow.log"
	scp centos@172.31.25.227:/tmp/mysql-slow.log ./

kataribe:
	sudo cp /var/log/h2o/access.log /tmp/last-access.log && sudo chmod 666 /tmp/last-access.log
	cat /tmp/last-access.log | ./kataribe -conf kataribe.toml > /tmp/kataribe.log
	cat /tmp/kataribe.log

