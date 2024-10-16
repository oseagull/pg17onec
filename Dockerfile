FROM ubuntu:jammy

COPY ./pgpro-repo-add.sh /
COPY ./entrypoint.sh /
COPY ./check_space.sh /usr/local/bin/check_space.sh
COPY ./pgdefault.conf /

# Disable some questions
ENV DEBIAN_FRONTEND=noninteractive
# Time zone variable
ENV TZ=Europe/Moscow

# install locales (languages)? Geographic area: 8 - select Europe, Time zone 34 - select Moscow
RUN chmod +x /pgpro-repo-add.sh \
    && /pgpro-repo-add.sh \
    && apt update \
    && apt-get --yes install locales \
    && localedef -f UTF-8 -i ru_RU ru_RU.UTF-8 \
    && locale-gen ru_RU.UTF-8 \
    && locale-gen en_US.UTF-8 \
    && update-locale LANG=ru_RU.UTF-8 \
    && export LC_ALL=ru_RU.UTF-8 \
    && apt-get --yes install tzdata && ln -snf /usr/share/zoneinfo/"$TZ" /etc/localtime && echo "$TZ" > /etc/timezone \
    && apt-get --yes install postgrespro-1c-16 \
    && apt-get --yes install gosu \
    && apt-get --yes install pgagent \
    && cp /usr/share/postgresql/14/extension/pgagent* /opt/pgpro/1c-16/share/extension/ \
    && rm /pgpro-repo-add.sh \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* \
    && chmod +x /entrypoint.sh \
    && chmod +x /usr/local/bin/check_space.sh

EXPOSE 5432

# Default postgres data directory
ENV PGDATA=/var/lib/1c/pgdata
ENV PGSOCKET=/tmp/postgresql/socket

VOLUME ${PGDATA}

WORKDIR /usr/bin
ENTRYPOINT ["/entrypoint.sh"]
CMD ["./postgres"]

HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD ["/usr/local/bin/check_space.sh"]
