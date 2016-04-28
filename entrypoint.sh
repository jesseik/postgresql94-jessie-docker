#!/bin/bash
export USER_ID=$(id -u)
export GROUP_ID=$(id -g)
envsubst < /workdir/passwd.template > /tmp/passwd
export LD_PRELOAD=libnss_wrapper.so
export NSS_WRAPPER_PASSWD=/tmp/passwd
export NSS_WRAPPER_GROUP=/etc/group

# Export environment
printenv > /tmp/environment.sh
chmod a+x /tmp/environment.sh

# Add nss-wrapper environment to bashrc
echo "export LD_PRELOAD=libnss_wrapper.so" > /home/.bashrc
echo "export NSS_WRAPPER_PASSWD=/tmp/passwd" >> /home/.bashrc
echo "export NSS_WRAPPER_GROUP=/etc/group" >> /home/.bashrc

# Check if variables have been set
if [ -z ${POSTGRESQL_USER+x} ]; then
  echo "POSTGRESQL_USER must be set.";
  exit 1
fi

if [ -z ${POSTGRESQL_DATABASE+x} ]; then
  echo "POSTGRESQL_DATABASE must be set.";
  exit 1
fi

if [ -z ${POSTGRESQL_PASSWORD+x} ]; then
  echo "POSTGRESQL_PASSWORD must be set.";
  exit 1
fi

# Initialize PostgreSQL
if [ ! -d /volume/postgresql-data ]; then
  # Create initial database
  /usr/lib/postgresql/9.4/bin/initdb -D /volume/postgresql-data

  # Initialize users and databases
  /usr/lib/postgresql/9.4/bin/pg_ctl -D /volume/postgresql-data/ -w start -o "-h ''"

  /usr/lib/postgresql/9.4/bin/createuser "$POSTGRESQL_USER"
  /usr/lib/postgresql/9.4/bin/createdb --owner="$POSTGRESQL_USER" "$POSTGRESQL_DATABASE"
  /usr/lib/postgresql/9.4/bin/psql --command "ALTER USER \"${POSTGRESQL_USER}\" WITH ENCRYPTED PASSWORD '${POSTGRESQL_PASSWORD}';"

  # Add UUID generation module
  /usr/lib/postgresql/9.4/bin/psql -d "$POSTGRESQL_DATABASE" --command "CREATE EXTENSION \"uuid-ossp\";"

  /usr/lib/postgresql/9.4/bin/pg_ctl -D /volume/postgresql-data/ stop
fi

# Create temporary statistics file, need for this is not confirmed
mkdir -p /var/run/postgresql/9.4-main.pg_stat_tmp/
touch /var/run/postgresql/9.4-main.pg_stat_tmp/global.tmp

exec "/usr/bin/supervisord"
