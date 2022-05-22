# CJ's Management System
- FIRST Lego League Management system used for WA FLL Events.
- Built to automate, store, display and simplify scoring teams in FLL.
# 2022 UPDATE IN DEVELOPMENT

[![Build Status](https://dev.azure.com/ConnorBuchel0890/ConnorBuchel/_apis/build/status/CJBuchel.CJ-MS?branchName=master)](https://dev.azure.com/ConnorBuchel0890/ConnorBuchel/_build/latest?definitionId=20&branchName=master)
![Docker Pulls](https://img.shields.io/docker/pulls/cjbuchel/cjms)
![Docker Image Version (latest by date)](https://img.shields.io/docker/v/cjbuchel/cjms)
![Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/cjbuchel/cjms)
## Production Install
- This Project is published as a docker image to package up dependencies for easy deployment to devices.
- You can view the docker image here https://hub.docker.com/r/cjbuchel/cjms
- However this still requires setup for anyone who has not used docker
- Installation Steps:
  - Prerequisites:
    - Install [Docker](https://docs.docker.com/get-docker/)
  - Creating the CJMS Image
    - Pull the docker image via the command `docker pull cjbuchel/cjms` alternatively `docker pull cjbuchel/cjms:<version tag>` for a specific version
  - Running the image in a container
    - Run the command `docker run -d -it -p 2000-3000:2000-3000 --name cjms cjbuchel/cjms` or with `cjbuchel/cjms:<version tag>`
    - The prior command will run the image in a container named `cjms`, with the exposed ports from `2000-3000`. And by default the image will use the `cjbuchel/cjms:latest` tag when none is specified.
    - Note that first time running will take a few minutes to setup. Subsequent stopping and starting of the container will be faster
- Running the CJMS
  - Commands:
    - `docker stop cjms` to stop the cjms container (if named cjms)
    - `docker start cjms` to start the cjms container
    - `docker container ls -a` to list the status of the containers active and inactive
    - `docker attach cjms` attach to the container and view console `Ctrl+p+q` will exit, `Ctrl+c` wil stop the container
    - `docker rm cjms` this will remove the container and all it's data. (Use only if you're updating to a newer version WILL DELETE DATABASE)

## Docker/Docker Compose Install
- Using [Docker-Compose](https://docs.docker.com/compose/install/) we can also clone the project locally and spin up the docker images for more customization
- Installation Steps:
  - Prerequisites:
    - [Node.js](https://nodejs.org/en/download/)
    - [Git](https://git-scm.com/downloads)
    - [Docker](https://docs.docker.com/get-docker/)
    - [Docker-Compose](https://docs.docker.com/compose/install/)
    - Clone the project locally using `git clone https://github.com/CJBuchel/CJ-MS.git`
  - Building/Start Image locally
    - To build/start the project run `docker-compose up --build`
    - Or just build using `docker-compose build --pull`
- Customize the compose file inside `CJ-MS/docker-compose.yml` for your own needs
- Running the CJMS
  - Commands:
    - `npm install -g yarn`
    - `yarn install`
    - `yarn run build`
    - `docker-compose build`
    - `docker run -d -it -p 2000-3000:2000-3000 --name cjms cjbuchel/cjms`

## Manual/Development Build
- Using the raw project and building locally for live reactive changes is also possible
- Not recommended for any events or persons who are prone to... deleting files by accident :)
- Installation Steps:
  - Prerequisites:
    - [Node.js](https://nodejs.org/en/download/)
    - [Git](https://git-scm.com/downloads)
    - [mysql](https://dev.mysql.com/doc/mysql-getting-started/en/)
  - Setting up Database
    - Start the mysql server
    - Create a database called `cjms-database` on port `3306`
    - Create an admin user called `cjms` with a password of `cjms` <- this is secure as the server is the only service that can interface with the database directly.
    - Afterwards, import the `Database/setup.sql` file into the mysql server using `mysql -u cjms -p cjms < setup.sql`
  - Installing Dependencies. Inside the root project run
    - `npm install -g yarn`
    - `yarn install`
    - `yarn run build`
- Running the CJMS
  - Commands:
    - `yarn run start`
  
## Port Numbers And rememberals
### Database/Storage
- Database port: `27017` (internal unless specified otherwise)

### Server
- Request Server Port: `2121`
- Comm Server Port: `2122`

### Interfaces
- Admin: `3000`
- Status Controller: `2827`
- Clock/Timer: `2828`
- Scoreboard: `2829`
- Judge Display: `2830`
- Scoring: `2832`