####################################################################################################
## Builder
####################################################################################################
# # This should be done in azure pipelines when deploying
# FROM rust:3.17 as builder

# RUN rustup target add x86_64-unknown-linux-musl
# RUN apt update && apt install -y musl-tools musl-dev
# RUN update-ca-certificates

# # Create appuser
# ENV USER=tms
# ENV UID=10001

# RUN adduser \
#     --disabled-password \
#     --gecos "" \
#     --home "/nonexistent" \
#     --shell "/sbin/nologin" \
#     --no-create-home \
#     --uid "${UID}" \
#     "${USER}"

# WORKDIR /tms_server
# COPY ./server .

# RUN cargo build --target x86_64-unknown-linux-musl --release

####################################################################################################
## Final
####################################################################################################
FROM nginx:stable-alpine3.17-slim as nginx

WORKDIR /tms

#!/bin/sh
RUN apk add openrc

# Setup server
COPY ./server/target/x86_64-unknown-linux-musl/release/tms_server .
COPY ./docker/nginx.conf /etc/nginx/nginx.conf

# Setup web ap
RUN rm -rf /usr/share/nginx/html/*
COPY ./tms/build/web ./tms_web
RUN chmod -R 755 tms_web
RUN ls
RUN ls ./tms_web

# Setup entrypoint
COPY ./docker/docker-start.sh .
RUN chmod +x ./docker-start.sh

EXPOSE 2121
EXPOSE 8080

CMD [ "./docker-start.sh" ]