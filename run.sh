#!/bin/bash
# Dev launcher for CJMS
yarn run build
sudo docker-compose build
sudo docker run -d -it -p 2000-3000:2000-3000 --name cjms cjbuchel/cjms