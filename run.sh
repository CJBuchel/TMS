#!/bin/bash
# Dev launcher for CJMS in docker container
yarn run build
sudo docker-compose build
sudo docker run -d -it -p 2000-3000:2000-3000 -p 9906:3306 --name cjms cjbuchel/cjms