# Развёртывание постгрес

## Вариант 1 (в докер)

1. Установить `docker`, в debian подобных ОС (debian, ubuntu):
```shell
apt-get update && apt-get --yes install docker
```
2. Построить имидж файл для запуска
```shell
docker build --tag pg161c .
```
3. Создать место хранения данных
```shell
docker volume create pg1c_pg161c_data
```
4. Создать и запустить контейнер с базой данных
  - domainname - доменное имя
  - env=PG_PASSWORD= - пароль по умолчанию для пользователя postgres
```shell
docker run -e LC_ALL=ru_RU.UTF-8 --detach --name=pg161c --hostname=pg161c --publish 5432:5432 --volume=pg1c_pg161c_data:/var/lib/1c/pgdata --env=PG_PASSWORD=uehBeDIyZraK --restart=always pg161c
```
Если контенейр контейнер успешно запущен то на порту 5432 виден postgres
4. Остановить контейнер c базой данных
```shell
docker stop pg161c
```
5. Снова запустить уже существующий контейнер (параметры запуска принадлежат контенейру)
```shell
docker start pg161c
```

## Вариант 2

Команды установки в Ubuntu лежат внутри Dockerfile
