# CJ's Management System
- FIRST Lego League Management system used for WA FLL Events.
- Built to automate, store, display and simplify scoring teams in FLL.
# 2023 UPDATE IN DEVELOPMENT (view flutter-2023 branch)

[![Build Status](https://dev.azure.com/ConnorBuchel0890/ConnorBuchel/_apis/build/status/CJBuchel.CJ-MS?branchName=master)](https://dev.azure.com/ConnorBuchel0890/ConnorBuchel/_build/latest?definitionId=20&branchName=master)
![Docker Pulls](https://img.shields.io/docker/pulls/cjbuchel/cjms)
![Docker Image Version (latest by date)](https://img.shields.io/docker/v/cjbuchel/cjms)
![Docker Image Size (latest by date)](https://img.shields.io/docker/image-size/cjbuchel/cjms)
## Production Install
- This Project is published as a docker image to package up dependencies for easy deployment to devices.
- You can view the docker image here https://hub.docker.com/r/cjbuchel/cjms
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

## Sound Notice
- Chrome's new update makes auto playing sounds an impossibility without user intervention of some kind. 
- To bypass this you must whitelist the website and allow sound. Click the info icon/lock symbol left of the site url, and then navigate to site settings -> sound, and then change to allow.
- You should be able to reload and save. For every new ip address you will need to re-complete this action. (It's recommended to use the server as the sound player, as `localhost:2828` once whitelisted should never change)
- Similar actions may need to be taken in safari and/or other untested browsers.

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
    - [Docker](https://docs.docker.com/get-docker/)
  - Setting up Database
    - Spin up a mongodb docker container using the included [script](/Database/scripts/create_local.sh)
      - Or alternatively spin it up manually `docker run -d -it -p 27017:27017 -e MONGO_INITDB_ROOT_USERNAME=cjms -e MONGO_INITDB_ROOT_PASSWORD=cjms -e MONGO_INITDB_DATABASE=cjms_database --name cjms_db -d mongo`
    - The database should now be named `cjms_db` on port `27017`,  with the default user and password `cjms`
  - Installing Dependencies. Inside the root project run
    - `npm install -g yarn`
    - `yarn install`
    - `yarn run build`
    - `./docker-create-env.sh` <- if possible. Otherwise the comm server passwords and environment will be blank
- Running the CJMS
  - Commands:
    - `yarn run start`
  
## Port Numbers
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
