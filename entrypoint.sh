#!/bin/bash

set -e

terminate_processes() {

    echo "Stopping postgres..."
    postgres_pid=$(ps -eo pid,cmd | grep '/opt/pgpro/1c-16/bin/postgres' | grep -v grep | awk '{print $1}')
    kill -SIGTERM "$postgres_pid" &

    echo "Stopping pgagent..."
    kill -SIGTERM "$pgagent_pid"

    wait "$postgres_pid"
    echo "Processes stopped."
    exit 0
}

trap 'terminate_processes' SIGTERM SIGINT

initialize_database() {
    # Early return if the database is already initialized
    if [ -s "$PGDATA/PG_VERSION" ]; then
        return
    fi
    chown -R postgres:postgres "$PGDATA"
    if [ -n "$PG_PASSWORD" ]; then
        gosu postgres sh -c 'echo "$PG_PASSWORD" > /tmp/password_file'
        gosu postgres ./initdb --pwfile=/tmp/password_file
    else
        gosu postgres ./initdb
    fi
    echo "synchronous_commit = off" >> "$PGDATA/postgresql.conf"
    echo "unix_socket_directories = '/tmp,$PGSOCKET'" >> "$PGDATA/postgresql.conf"
    echo "listen_addresses = '*'" >> "$PGDATA/postgresql.conf"
    echo "host  all  all  0.0.0.0/0  md5" >> "$PGDATA/pg_hba.conf"
    cat /pgdefault.conf >> /var/lib/1c/pgdata/postgresql.conf
    rm /pgdefault.conf
}

initialize_socket() {
    # Early return if the socket directory already exists
    if [ -d "$PGSOCKET" ]; then
        chown postgres $PGSOCKET
        return
    fi
    mkdir -p $PGSOCKET
    chown postgres $PGSOCKET
}

start_processes() {
    echo "Staring pgagent..."
    gosu postgres pgagent -f host=$PGSOCKET dbname=postgres &
    pgagent_pid=$!
    echo "Starting postgres..."
    gosu postgres ./postgres &
    postgres_pid=$!
    wait "$postgres_pid"
}

if [ "$1" = './postgres' ]; then
    initialize_database
    initialize_socket
    start_processes
fi

exec "$@"
