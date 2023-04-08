
// Main steps for server client connection
// Broadcast a udp packet on port 2122 with the server ip and status (tells client where server is)
// Client will then connect to port 2121 on websocket.
// Server will accept the connection and store the UUID in a tabled map
// Client will request public key
// Client will send it's own public key to server (encrypted)
// Server store this public key along with the UUID of the client

// <-> Two way communication pub sub messaging

// mod schemas;
#[tokio::main]
async fn main() {

}