FROM nginx:stable-alpine3.17-slim as nginx

WORKDIR /tms

# Setup server
COPY ./server/target/x86_64-unknown-linux-musl/release/tms_server .
COPY ./docker/nginx.conf /etc/nginx/nginx.conf

# Setup web ap
RUN rm -rf /usr/share/nginx/html/*
COPY ./client/build/web ./tms_web
RUN chmod -R 755 tms_web
RUN ls
RUN ls ./tms_web

# Setup entrypoint
COPY ./docker/docker-start.sh .
RUN chmod +x ./docker-start.sh

EXPOSE 2121
EXPOSE 2122
EXPOSE 5353
EXPOSE 8080

ENTRYPOINT [ "./docker-start.sh" ]