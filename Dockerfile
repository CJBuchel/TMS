FROM alpine:3.18

WORKDIR /tms

# Setup server
COPY ./target/x86_64-unknown-linux-musl/release/tms_server .
COPY ./log_config ./log_config
COPY ./tms_client/build/web ./tms_client/build/web

RUN chmod +x tms_server

EXPOSE 8080

ENTRYPOINT [ "./tms_server" ]