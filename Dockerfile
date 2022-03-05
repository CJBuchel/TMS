# CJMS Database
FROM mysql
# Environemnt Variables
ENV MYSQL_HOST: localhost
ENV MYSQL_DATABASE cjms-database
ENV MYSQL_ROOT_PASSWORD root
ENV MYSQL_USER cjms
ENV MYSQL_PASSWORD cjms

# MYSQL Internal Ports
EXPOSE 3306/tcp
EXPOSE 3306/udp

COPY ./Database/ ./docker-entrypoint-initdb.d/

# Main Core CJMS System
FROM node

# CJMS Internal Ports
EXPOSE 2000-3000/tcp
EXPOSE 2000-3000/udp
WORKDIR /cmjs

COPY ./ ./

RUN yarn install
RUN ls -la ./
RUN yarn run build
RUN ls -la ./

CMD ["yarn", "run", "start"]