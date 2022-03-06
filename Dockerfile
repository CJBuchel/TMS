
# CJMS Database
FROM mysql as mysql_stage
COPY ./Database/scripts/*.sql /docker-entrypoint-initdb.d/

# Main Core CJMS System
FROM node as node_stage

# Did somone say inefficiency?
COPY --from=mysql_stage / /

WORKDIR /cjms

# Environemnt Variables
ENV MYSQL_HOST: localhost
ENV MYSQL_DATABASE cjms-database
ENV MYSQL_ROOT_PASSWORD root
ENV MYSQL_USER cjms
ENV MYSQL_PASSWORD cjms

EXPOSE 3306/tcp
EXPOSE 3306/udp
EXPOSE 2000-3000/tcp
EXPOSE 2000-3000/udp

# COPY ./ ./
WORKDIR /cjms

# Copy CJMS App to the docker image dir /cjms
COPY ./CJMS-Interfaces ./CJMS-Interfaces
COPY ./CJMS-Servers ./CJMS-Servers
COPY ./package.json ./
COPY ./lerna.json ./
COPY ./yarn.lock ./
COPY ./node_modules ./node_modules
COPY ./docker-start.sh ./

# Install deps and scripts
RUN apt-get -y update
RUN apt-get install -y net-tools
RUN chmod +x ./docker-start.sh

# Execute docker start script on container start
CMD ["./docker-start.sh"]