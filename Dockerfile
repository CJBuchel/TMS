FROM nginx:stable-alpine3.17-slim as nginx

WORKDIR /tms

# Setup server
COPY ./target/x86_64-unknown-linux-musl/release/tms_server .
COPY ./log_conifg ./log_config
COPY ./tms-client/build/web ./tms-client/build/web

RUN chmod +x tms_server

EXPOSE 8080

ENTRYPOINT [ "./tms_server" ]