use std::error::Error;

use tokio::signal;
use tokio::sync::oneshot;
use warp::http::{Response, StatusCode};
use warp::{self, path, Filter};

#[tokio::main]
async fn main() -> Result<(), Box<dyn Error>> {
    // GET /hello/warp => 200 OK with body "Hello, warp!"
    //    let hello = path!("hello" / String).map(|name| format!("Hello, {}!", name));
    let hello = warp::path("hello")
        .and(warp::path::param()) // number
        .and(warp::path::param()) // name
        .and(warp::get())
        .and(warp::header("User-Agent")) // user_agent
        .map(handle_hello);
    let bonjour = path!("bonjour" / String / String)
        .and(warp::get())
        .map(|title: String, name: String| format!("Bonjour, {} {}", title, name));

    let (tx, rx) = oneshot::channel();

    let server = warp::serve(hello.or(bonjour));
    let (_addr, server) = server.bind_with_graceful_shutdown(([127, 0, 0, 1], 3030), async move {
        rx.await.ok();
    });
    tokio::task::spawn(server);

    signal::ctrl_c().await?;
    let _ = tx.send(());

    println!("server shutting down");
    Ok(())
}

fn handle_hello(number: String, name: String, user_agent: String) -> impl warp::Reply {
    let number: u32 = match number.parse() {
        Ok(n) => n,
        Err(_) => {
            return Response::builder()
                .status(StatusCode::BAD_REQUEST)
                .header("x-you-suck", "true")
                .body(format!(
                    "/hello/number/name : number needs to be an unsigned 32-bit integer value"
                ));
        }
    };
    Response::builder().body(format!(
        "Hello, number {}: {} from {}",
        number, name, user_agent
    ))
}
