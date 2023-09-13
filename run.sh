#!/bin/sh

# run with --no-server or --no-client to skip that startup in docker

# rustup target add x86_64-unknown-linux-musl
# sudo apt update && apt install -y musl-tools musl-dev openssl
# sudo update-ca-certificates

sudo docker stop tms
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


if [ "$RUN_SERVER" = true ] ; then
  (cd ./server; cargo build --target x86_64-unknown-linux-musl --release)
fi

if [ "$RUN_CLIENT" = true ] ; then
  (cd ./client; npm run prepare; flutter build web --release)
fi


sudo docker-compose build


if [ "$RUN_SERVER" = false ] ; then
  echo "NO SERVER MODE"
  sudo docker run -it -p 8080:8080 --name tms cjbuchel/tms --no-server
elif [ "$RUN_CLIENT" = false ] ; then
  sudo docker run -it -p 2121:2121 -p 2122:2122 -p 5353:5353 --name tms cjbuchel/tms --no-client
else
  sudo docker run -it -p 8080:8080 -p 2121:2121 -p 2122:2122 -p 5353:5353 --name tms cjbuchel/tms "$@"
fi