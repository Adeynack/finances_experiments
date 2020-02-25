use std::convert::Infallible;
use std::net::SocketAddr;
use std::sync::Arc;

use hyper::{Body, http, Method, Request, Response, Server};
use hyper::service::{make_service_fn, service_fn};
use regex::{Captures};

use crate::routes::{RouteCreationError, Router};

mod routes;

#[tokio::main]
async fn main() {
    let addr = SocketAddr::from(([127, 0, 0, 1], 3030));

    let router = Arc::new(initialize_router().expect("initializing router"));

    let service = make_service_fn(move |_| {
        println!("1️⃣  make_service_fn  ⚠️ cloning 'router'");
        let router = router.clone();
        async move {
            println!("2️⃣  make_service_fn / async move  ⚠️ cloning 'router'");
            let router = router.clone();
            Ok::<_, Infallible>(service_fn(move |req| {
                println!("3️⃣  service_fn  ⚠️ cloning 'router'");
                let router = router.clone();
                async move {
                    println!("4️⃣ service_fn / async move");
                    router.handle(req).await
                }
            }))
        }
    });

    let server = Server::bind(&addr).serve(service);
    println!("listening at http://{}", addr);

    if let Err(e) = server.await {
        eprintln!("server error: {}", e);
    }
}

fn initialize_router() -> Result<Router, RouteCreationError> {
    let mut router = Router::new();

    router.route(Method::GET, "/?foo/?", handle_foo)?;
//    router.route(Method::GET, "/?hello/(?<number>\\w*)/(?<name>\\w*)?/?", handle_hello)?;
    router.route(Method::GET, "/?hello/(\\w*)/(\\w*)?/?", handle_hello)?;
//    router.route(Method::GET, "/?bonjour/(?<title>\\w*)/?(?<name>\\w*)?/?", handle_bonjour)?;
    router.route(Method::GET, "/?bonjour/(\\w*)/?(\\w*)?/?", handle_bonjour)?;

    Ok(router)
}

fn handle_foo(req: Request<Body>, captures: Captures) -> http::Result<Response<Body>> {
    println!("handle_foo / Path: {} / Captures: {:?}", req.uri().path(), captures);
    Response::builder().body(Body::default())
}

fn handle_hello(req: Request<Body>, captures: Captures) -> http::Result<Response<Body>> {
    println!("handle_hello / Path: {} / Captures: {:?}", req.uri().path(), captures);
    Response::builder().body(Body::default())
}

fn handle_bonjour(req: Request<Body>, captures: Captures) -> http::Result<Response<Body>> {
    println!("handle_bonjour / Path: {} / Captures: {:?}", req.uri().path(), captures);
    Response::builder().body(Body::default())
}

//async fn handle(req: Request<Body>) -> http::Result<Response<Body>> {
//    println!("Request: {:#?}", req);
//
//    let mut parts = req.uri().path().split('/').filter(|p| p.len() > 0);
//    let mut response: Option<http::Result<Response<Body>>> = None;
//
//    match parts.next() {
//        Some("hello") => {
//            if let Some(number) = parts.next() {
//                if let Some(name) = parts.next() {
//                    if let None = parts.next() { // ensure it was the last part of the path
//                        response = Some(handle_hello(&req, number, name).await);
//                    }
//                }
//            }
//        }
//        Some("bonjour") => {
//            if let Some(first_part) = parts.next() {
//                if let Some(second_part) = parts.next() {
//                    if let None = parts.next() {
//                        response = Some(handle_bonjour(Some(first_part), second_part).await);
//                    }
//                } else {
//                    response = Some(handle_bonjour(None, first_part).await);
//                }
//            }
//        }
//        _ => {}
//    };
//
//    response.unwrap_or_else(|| {
//        Response::builder()
//            .status(StatusCode::NOT_FOUND)
//            .body(Body::from(format!("Nothing found at {}", req.uri().path())))
//    })
//}

//async fn handle_hello(req: &Request<Body>, number: &str, name: &str) -> http::Result<Response<Body>> {
//    let number: u32 = match number.parse() {
//        Ok(n) => n,
//        Err(_) => {
//            return Response::builder()
//                .status(StatusCode::BAD_REQUEST)
//                .header("x-you-failed", "oh so much")
//                .body(Body::from(format!("/hello/number/name : number needs to be an unsigned 32-bit integer value")));
//        }
//    };
//
//    let user_agent: &str = req.headers().get("User-Agent")
//        .and_then(|v| v.to_str().ok())
//        .unwrap_or("<unspecified>");
//
//    Response::builder()
//        .status(StatusCode::OK)
//        .body(Body::from(format!("Hello, number {}: {} from {}", number, name, user_agent)))
//}
//
//async fn handle_bonjour(title: Option<&str>, name: &str) -> http::Result<Response<Body>> {
//    Response::builder()
//        .status(StatusCode::OK)
//        .body(Body::from(match title {
//            Some(title) => format!("Bonjour, {} {}", title, name),
//            None => format!("Bonjour, {}", name),
//        }))
//}