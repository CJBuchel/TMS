# CJ's Management System
- FIRST Lego League Management system used for WA FLL Events.
- Built to automate, store display and simplify scoring teams in FLL.
# 2022 UPDATE IN DEVELOPMENT

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
    - Run the command `docker run -d -p 2000-3000:2000-3000 -p 9906:3306 --name cjms cjbuchel/cjms` or with `cjbuchel/cjms:<version tag>`
    - The prior command will run the image in a container named `cjms`, with the exposed ports from `2000-3000`, along with the database port `9906` as to not conflict with any existing `3306` db ports already in use. And by default the image will use the `cjbuchel/cjms:latest` tag when none is specified.
- Running the CJMS
  - Commands:
    - `docker stop cjms` to stop the cjms container (if named cjms)
    - `docker start cjms` to start the cjms container
    - `docker container ls -a` to list the status of the containers active and inactive



## Port Numbers And rememberals
### Database/Storage
- Database port:  `9906`

### Server
- Server Port:     3001