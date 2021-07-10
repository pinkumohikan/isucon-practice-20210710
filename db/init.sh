#!/bin/bash

ROOT_DIR=$(cd $(dirname $0)/..; pwd)
DB_DIR="$ROOT_DIR/db"
BENCH_DIR="$ROOT_DIR/bench"

export MYSQL_PWD=isucon

mysql -uisucon  -h172.31.25.227 -pRB*Cm7Yre.KZ-dTx4djh@k.x -e "DROP DATABASE IF EXISTS torb; CREATE DATABASE torb;"
mysql -uisucon  -h172.31.25.227 -pRB*Cm7Yre.KZ-dTx4djh@k.x torb < "$DB_DIR/schema.sql"

if [ ! -f "$DB_DIR/isucon8q-initial-dataset.sql.gz" ]; then
  echo "Run the following command beforehand." 1>&2
  echo "$ ( cd \"$BENCH_DIR\" && bin/gen-initial-dataset )" 1>&2
  exit 1
fi

mysql -uisucon   -h172.31.25.227 -pRB*Cm7Yre.KZ-dTx4djh@k.x torb -e 'ALTER TABLE reservations DROP KEY event_id_and_sheet_id_idx'
gzip -dc "$DB_DIR/isucon8q-initial-dataset.sql.gz" | mysql -uisucon   -h172.31.25.227 -pRB*Cm7Yre.KZ-dTx4djh@k.x torb
mysql -uisucon torb  -h172.31.25.227 -pRB*Cm7Yre.KZ-dTx4djh@k.x -e 'ALTER TABLE reservations ADD KEY event_id_and_sheet_id_idx (event_id, sheet_id)'

mysql -uisucon  torb  -h172.31.25.227 -pRB*Cm7Yre.KZ-dTx4djh@k.x -e 'alter table `reservations` add index (`sheet_id`);'
mysql -uisucon  torb -h172.31.25.227 -pRB*Cm7Yre.KZ-dTx4djh@k.x -e 'alter table `reservations` add index (`user_id`);'
mysql -uisucon  torb -h172.31.25.227 -pRB*Cm7Yre.KZ-dTx4djh@k.x -e 'alter table `reservations` add index (`event_id`,`canceled_at`);'
