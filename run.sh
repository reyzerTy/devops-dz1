#!/usr/bin/env bash
set -e

PREFIX=ustyzanina-02
IMAGE=${PREFIX}/probe:2.0
WEB=${PREFIX}-web
DB=${PREFIX}-db
VOL=${PREFIX}-data
PUB=8006
INNER=5002
DBPORT=8008

# 1. Удаляем прежние контейнеры (том НЕ удаляем!)
docker rm -f ${WEB} ${DB} 2>/dev/null || true

# 2. Сборка образа 2.0
docker build --build-arg VERSION=2.0 -t ${IMAGE} .

# 3. Том для данных
docker volume create ${VOL}

# 4. База на томе
docker run -d --name ${DB} \
  -e MARIADB_ROOT_PASSWORD=lab \
  -e MARIADB_DATABASE=lab \
  -p ${DBPORT}:3306 \
  -v ${VOL}:/var/lib/mysql \
  mariadb:11

# 5. Приложение
docker run -d --name ${WEB} \
  --add-host host.docker.internal:host-gateway \
  -e DATABASE_URL="mysql://root:lab@host.docker.internal:${DBPORT}/lab" \
  -p ${PUB}:${INNER} \
  ${IMAGE}

# 6. Ожидание готовности базы (до 60 секунд)
SECONDS=0
until curl -sf -m 3 localhost:${PUB}/notes > /dev/null || [ $SECONDS -ge 60 ]; do
  sleep 2
done
curl -s localhost:${PUB}/notes
echo
