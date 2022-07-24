#!/bin/bash 
set -euo pipefail

PGB_DIR="/home/pgbouncer"
INI="${PGB_DIR}/pgbouncer.ini"
USERLIST="${PGB_DIR}/userlist.txt"

rm -f "${INI}" "${USERLIST}"

if [[ -z "${PGB_DATABASE1:-}" ]]; then
  echo "Error: no databases specified in \$PGB_DATABASES"
  exit 1
fi

if [ -z ${PGB_ADMIN_USERS+x} ]; then
  PGB_ADMIN_USERS="admin"
  PGB_ADMIN_PASSWORDS="pw"
fi

cat <<- END > $INI
[databases]
    $PGB_DATABASE1
    $PGB_DATABASE2
    $PGB_DATABASE3
[pgbouncer]
    listen_port = ${PGB_LISTEN_PORT:-5432}
    listen_addr = ${PGB_LISTEN_ADDR:-0.0.0.0}
    auth_type = md5
    default_pool_size = $default_pool_size
    log_connections = $log_connections
    log_disconnections = $log_disconnections
    log_pooler_errors = $log_pooler_errors
    routing_rules_py_module_file = $routing_rules_py_module_file
    log_stats = $log_stats
    auth_file = $USERLIST
    logfile = $PGB_DIR/pgbouncer.log
    pidfile = $PGB_DIR/pgbouncer.pid
    admin_users = ${PGB_ADMIN_USERS:-admin}
END

cat $INI

# convert comma-separated string variables to arrays.
IFS=',' read -ra admin_array <<< "$PGB_ADMIN_USERS"
IFS=',' read -ra password_array <<< "$PGB_ADMIN_PASSWORDS"

# check every admin account has a corresponding password, and vice versa
if (( ${#admin_array[@]} != ${#password_array[@]} )); then
    exit 1
fi

# Zip admin arrays together and write them to userlist.
for (( i=0; i < ${#admin_array[*]}; ++i )); do
    echo "\"${admin_array[$i]}\" \"${password_array[$i]}\"" >> $USERLIST
done

chmod 0600 $INI
chmod 0600 $USERLIST
/pub_metrics.sh &
/adaptivepgbouncer.sh &
pgbouncer $INI
