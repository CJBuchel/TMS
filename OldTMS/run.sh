#!/bin/sh

# run with --no-server or --no-client to skip the startup in docker

# rustup target add x86_64-unknown-linux-musl
# sudo apt update; sudo apt install -y musl-tools musl-dev openssl
# sudo update-ca-certificates

sudo docker stop tms # graceful break out of loops rusdock
sudo docker rm tms
sudo docker image rm cjbuchel/tms

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


(cd ./server; cargo build --target x86_64-unknown-linux-musl --release)
(cd ./client; npm run prepare; flutter build web --release --no-web-resources-cdn --web-renderer canvaskit)

sudo docker compose build


if [ "$RUN_SERVER" = false ] ; then
  echo "NO SERVER MODE"
  sudo docker run --network host -it --name tms cjbuchel/tms --no-server
elif [ "$RUN_CLIENT" = false ] ; then
  sudo docker run --network host -it --name tms cjbuchel/tms --no-client
else
  sudo docker run --network host -it --name tms cjbuchel/tms "$@"
fi