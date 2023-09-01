
# rustup target add x86_64-unknown-linux-musl
# sudo apt update && apt install -y musl-tools musl-dev openssl
# sudo update-ca-certificates

$(cd ./server; cargo build --target x86_64-unknown-linux-musl --release)
# $(cd ./client; npm run prepare; flutter build web --release)
sudo docker-compose build
sudo docker run -it -p 8080:8080 -p 2121:2121 -p 2122:2122 -p 5353:5353 --name tms cjbuchel/tms