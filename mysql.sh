#!/bin/bash

sudo apt-get update
sudo apt-get install mysql-server

# add mysql workbench
snap install mysql-workbench-community
sudo snap connect mysql-workbench-community:password-manager-service :password-manager-service

sudo systemctl start mysql
sudo systemctl status mysql

sudo chmod +x create_db.sh
sudo ./server/mysql/create_db.sh