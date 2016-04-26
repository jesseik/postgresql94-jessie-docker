FROM debian:jessie

# Install nss-wrapper from unstable.
ADD apt/unstable.pref /etc/apt/preferences.d/unstable.pref
ADD apt/unstable.list /etc/apt/sources.list.d/unstable.list
RUN apt-get update && apt-get install -y -t unstable libnss-wrapper

# Install PostgreSQL packages
RUN rm -rf /etc/apt/preferences.d/unstable.pref && rm -rf /etc/apt/sources.list.d/unstable.list
RUN apt-get update && apt-get install -y postgresql-9.4 postgresql-contrib-9.4 postgresql-client

# Install additional requirements
RUN apt-get install -y gettext supervisor

ADD config/passwd.template /workdir/passwd.template
ADD entrypoint.sh /workdir/entrypoint.sh
ADD backup.sh /workdir/backup.sh

# Copy PostgreSQL and Supervisor files
ADD config/postgresql.conf /etc/postgresql/9.4/main/postgresql.conf
ADD config/pg_hba.conf /etc/postgresql/9.4/main/pg_hba.conf

ADD config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN cp -rf /etc/ssl/certs/ssl-cert-snakeoil.pem /workdir/ && \
    cp -rf /etc/ssl/private/ssl-cert-snakeoil.key /workdir/ && \
    chown -R 0:0 /workdir/ssl-cert-snakeoil.* && \
    chmod -R a-rwx /workdir/ssl-cert-snakeoil.* && \
    chmod -R g+r /workdir/ssl-cert-snakeoil.*

# Create volume dir in case not mounted
RUN mkdir -p /volume

ENV HOME /home/
RUN chmod 777 /workdir/passwd.template
RUN chmod -R 777 /volume
RUN chmod -R 777 /var/run/postgresql
RUN chmod -R a+r /etc/postgresql/9.4/main
RUN chmod a+x /workdir/entrypoint.sh
RUN chmod a+x /workdir/backup.sh
RUN chmod -R 777 /home/

WORKDIR /workdir
VOLUME ["/volume"]

EXPOSE 5432
USER 1000000

ENTRYPOINT ["/workdir/entrypoint.sh"]
