mod Network;

use actix_web::{
  get,
  post,
  web,
  App,
  HttpResponse,
  HttpServer,
  Responder
};

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

#[actix_web::main]
async fn main() -> std::io::Result<()> {
  println!("Program starting");
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