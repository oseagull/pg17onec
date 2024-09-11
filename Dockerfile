FROM ubuntu:jammy

ADD ./scripts.tar /

# add postgrespro repository
RUN chmod +x /pgpro-repo-add.sh && /pgpro-repo-add.sh

# Disable some questions
ENV DEBIAN_FRONTEND=noninteractive
# Time zone variable
ENV TZ=Europe/Moscow

# install locales (languages)? Geographic area: 8 - select Europe, Time zone 34 - select Moscow
RUN apt update \
    && apt-get --yes install locales \
    && localedef -f UTF-8 -i ru_RU ru_RU.UTF-8 \
    && locale-gen ru_RU.UTF-8 \
    && update-locale LANG=ru_RU.UTF-8 \
    && export LC_ALL=ru_RU.UTF-8 \
    && apt-get --yes install tzdata && ln -snf /usr/share/zoneinfo/"$TZ" /etc/localtime && echo "$TZ" > /etc/timezone \
    && apt-get --yes install postgrespro-1c-16 \
    && apt-get --yes install gosu \
    && rm /pgpro-repo-add.sh \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

RUN chmod +x /entrypoint.sh \
    && chmod +x ./postgres

EXPOSE 5432

ENV PGDATA /var/lib/1c/pgdata
ENV PGSOCKET /tmp/postgresql/socket
ENV PG_PASSWORD="postgres"

VOLUME ${PGDATA}

WORKDIR /usr/bin
ENTRYPOINT ["/entrypoint.sh"]
CMD ["./postgres"]
