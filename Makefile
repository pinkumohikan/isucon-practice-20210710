.PHONY: gogo all app bench slow-log kataribe
all: gogo

app:
	make -C webapp/go build

gogo:
	sudo systemctl stop h2o.service
	sudo systemctl stop torb.go.service
	sudo truncate --size 0 /var/log/h2o/access.log
	# sudo truncate --size 0 /var/log/mysql/mysql-slow.sql
	$(MAKE) app
	sudo systemctl start torb.go.service
	sudo systemctl start h2o.service
	sleep 2
	# make bench

bench:
	# ssh -i ~/.ssh/id_rsa centos@54.168.238.28 sudo su - isucon && cd /home/isucon/
	# ssh -i ~/.ssh/id_rsa centos@54.168.238.28 sudo jq . < result.json

slow-log:
	# sudo truncate --size 0 /home/mysql-slow.sql
	# sudo cp mysql/mysql-slow.sql /home/mysql-slow.sql
	# chown ubuntu /home/mysql-slow.sql

kataribe:
	sudo cp /var/log/h2o/access.log /tmp/last-access.log && sudo chmod 666 /tmp/last-access.log
	cat /tmp/last-access.log | ./kataribe -conf kataribe.toml > /tmp/kataribe.log
	cat /tmp/kataribe.log