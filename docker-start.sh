#!/bin/bash

retries=1
max_retries=5

printf '\e[1;32m'
printf "\nCreating random password\n"
printf '\e[0m'
./docker-create-password.sh

# Start Database
printf '\e[1;32m'
printf "\nStarting Database\n"
printf '\e[0m'
echo starting mongo
/usr/local/bin/docker-entrypoint.sh mongod &

# Start CJMS if db is up
sleep 5
while [ $retries -le $max_retries ]
do
  if netstat -tulpn | grep :27017 >/dev/null ; then
    printf '\e[1;32m'
    printf "\nDatabase Online: Starting CJMS\n"
    printf '\e[0m'
    yarn run start &
    retries=$((retries+max_retries))
  else
    printf '\e[1;31m'
    printf "\nCJMS Database Not Detected, Retry #$retries. Reloading in 30s...\n"
    printf '\e[0m'
    sleep 30
  fi

  retries=$((retries+1))
done

wait -n
exit $?