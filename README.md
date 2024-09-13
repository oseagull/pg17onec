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

6. После запуска
кидаем конфиг по умолчанию
```shell
cat /pgdefault.conf >> /var/lib/1c/pgdata/postgresql.conf
```
переписываем пароль на md5
```sql
ALTER USER postgres WITH PASSWORD 'uehBeDIyZraK';
SELECT usename, passwd FROM pg_shadow;
```

конфиг для базы побольше
```
shared_buffers = 2048MB
temp_buffers = 512MB
max_files_per_process = 10000
max_parallel_workers_per_gather = 0
max_parallel_maintenance_workers = 4
commit_delay = 1000
max_wal_size = 4GB
min_wal_size = 2GB
checkpoint_timeout = 15min
effective_cache_size = 3072MB
work_mem=1024MB
maintenance_work_mem = 2048MB
from_collapse_limit = 8
join_collapse_limit = 8
autovacuum_max_workers = 4
vacuum_cost_limit = 400
autovacuum_naptime = 20s
autovacuum_vacuum_scale_factor = 0.01
autovacuum_analyze_scale_factor = 0.005
max_locks_per_transaction = 256
escape_string_warning = off
standard_conforming_strings = off
track_activity_query_size = 10240
password_encryption = md5
```

При использовании порта отличного от 5432 например `--publish 5440:5432` в параметрах создания базы данных 1С следует указывать так `myhost.domain.local port=5440`

## Вариант 2

Команды установки в Ubuntu лежат внутри Dockerfile
