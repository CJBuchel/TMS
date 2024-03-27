#!/bin/sh

# Defaults
RUN_CLIENT=true
RUN_SERVER=true

# Process flags
for arg in "$@"; do
  case $arg in
    --no-client)
      RUN_CLIENT=false
      shift
      ;;
    --no-server)
      RUN_SERVER=false
      shift
      ;;
    *)
      shift
      ;;
  esac
done

if [ "$RUN_CLIENT" = true ] ; then
  printf '\e[1;32m'
  printf "\nStarting TMS Web\n"
  printf '\e[0m'
  /docker-entrypoint.sh nginx -g "daemon on;"
else
  printf '\e[1;33m'
  printf "\nSkipping TMS Web\n"
  printf '\e[0m'
fi

if [ "$RUN_SERVER" = true ] ; then
  printf '\e[1;32m'
  printf "\nStarting TMS Server\n"
  printf '\e[0m'
  ./tms_server
else
  printf '\e[1;33m'
  printf "\nSkipping TMS Server\n"
  printf '\e[0m'
  echo "Press [CTRL+C] to stop.."
  while :
  do
    sleep 1
  done
fi