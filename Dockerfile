
# CJMS Database
FROM mongo as database_stage

# Main Core CJMS System
FROM node as build_stage

# # Did somone say inefficiency?
COPY --from=database_stage / /
WORKDIR /cjms

# # Environemnt Variables
ENV MONGO_INITDB_ROOT_USERNAME=cjms
ENV MONGO_INITDB_ROOT_PASSWORD=cjms
ENV MONGO_INITDB_DATABASE: cjms_database

EXPOSE 27017/tcp
EXPOSE 27017/udp
EXPOSE 2000-3000/tcp
EXPOSE 2000-3000/udp


# Copy CJMS App to the docker image dir /cjms
COPY ./CJMS-Interfaces ./CJMS-Interfaces
COPY ./CJMS-Servers ./CJMS-Servers
COPY ./package.json ./
COPY ./lerna.json ./
COPY ./yarn.lock ./
COPY ./node_modules ./node_modules
COPY ./docker-start.sh ./

# # # Install deps and scripts
RUN apt-get -y update
RUN apt-get install -y net-tools
RUN chmod +x ./docker-start.sh

# # Execute docker start script on container start
CMD ["./docker-start.sh"]