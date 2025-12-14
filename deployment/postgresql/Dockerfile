ARG POSTGRES_TAG=latest
FROM postgres:${POSTGRES_TAG}

COPY secrets/certs/postgresql/postgresql.key /etc/postgresql/server.key
COPY secrets/certs/postgresql/postgresql.crt /etc/postgresql/server.crt
COPY secrets/certs/ca/ca.crt /etc/postgresql/ca.crt

RUN chmod 600 /etc/postgresql/server.key
RUN chown postgres:postgres /etc/postgresql/server.key

#RUN apt-get update \
#    && apt-get install -y --no-install-recommends locales \
#    && localedef -i de_DE -c -f UTF-8 -A /usr/share/locale/locale.alias de_DE.UTF-8 \
#    && rm -rf /var/lib/apt/lists/*
#
#ENV LANG de_DE.utf8

# Example: install additional packages (e.g. postgis)
# RUN apt-get update && apt-get install -y postgis postgresql-18-postgis-3