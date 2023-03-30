mod network;

use actix_web::{
  get,
  post,
  web,
  App,
  HttpResponse,
  HttpServer,
  Responder
};

use tokio::try_join;

#[get("/")]
async fn hello() -> impl Responder {
  println!("My my, a connection so sweet");
  HttpResponse::Ok().body("Hello world!")
}

#[post("/echo")]
async fn echo(req_body: String) -> impl Responder {
  HttpResponse::Ok().body(req_body)
}

async fn manual_hello() -> impl Responder {
  HttpResponse::Ok().body("Hey there!")
}

async fn actix() -> std::io::Result<()> {
  println!("Starting Request Server");
  HttpServer::new(|| {
    App::new()
    .service(hello)
    .service(echo)
    .route("/hey", web::get().to(manual_hello))
  })
  .bind(("0.0.0.0", 2121))?
  .run()
  .await
}


#[tokio::main]
async fn main() {
  println!("Program starting");
  
  // let actix_server = actix();
  // let network_server = network::network::start();

  // try_join!(async{ actix().await }, async { network::network::start().await });
  // actix().await.err();
  network::network::start().await;
}