#!/bin/bash

retries=1
max_retries=5

# Start MySQL
/entrypoint.sh mysqld &

# # Start CJMS if mysql is up
sleep 5
while [ $retries -le $max_retries ]
do
  if netstat -tulpn | grep :3306 >/dev/null ; then
    echo "CJMS Database Online. Starting CJMS"
    yarn run start &
    retries=$((retries+max_retries))
  else
    echo "CJMS Database Not Detected, Retry #$retries. Reloading in 30s..."
    sleep 30
  fi

  retries=$((retries+1))
done

wait -n
exit $?