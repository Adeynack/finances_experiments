use warp::{self, Filter, path};
use warp::http::{StatusCode, Response};

#[tokio::main]
async fn main() {
    // GET /hello/warp => 200 OK with body "Hello, warp!"
//    let hello = path!("hello" / String).map(|name| format!("Hello, {}!", name));
    let hello =
        warp::path("hello")
            .and(warp::path::param()) // number
            .and(warp::path::param()) // name
            .and(warp::header("User-Agent")) // user_agent
            .map(handle_hello);
    let bonjour = path!("bonjour" / String / String).map(|title, name| format!("Bonjour, {} {}", title, name));

    warp::serve(hello.or(bonjour)).run(([127, 0, 0, 1], 3030)).await;
}

fn handle_hello(number: String, name: String, user_agent: String) -> impl warp::Reply {
    let number: u32 = match number.parse() {
        Ok(n) => n,
        Err(_) => {
            return Response::builder()
                .status(StatusCode::BAD_REQUEST)
                .header("x-you-suck", "true")
                .body(format!("/hello/number/name : number needs to be an unsigned 32-bit integer value"))
        }
    };
    Response::builder()
        .body(format!("Hello, number {}: {} from {}", number, name, user_agent))
}
