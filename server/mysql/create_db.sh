#!/bin/bash

echo "You will need to enter mysql root password, usually it's either 'password', 'root' or no password"

sudo mysql -u root -p < db.sql