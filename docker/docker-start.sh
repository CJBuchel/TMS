#!/bin/sh
printf '\e[1;32m'
printf "\nStarting TMS Web\n"
printf '\e[0m'
/docker-entrypoint.sh nginx -g "daemon on;"


printf '\e[1;32m'
printf "\nStarting TMS Server\n"
printf '\e[0m'
./tms_server