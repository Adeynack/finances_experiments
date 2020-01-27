use std::convert::Infallible;
use std::net::SocketAddr;

use hyper::{Body, http, Request, Response, Server, StatusCode};
use hyper::service::{make_service_fn, service_fn};

#[tokio::main]
async fn main() {
    let addr = SocketAddr::from(([127, 0, 0, 1], 3030));

    let make_svc = make_service_fn(|_conn| async {
        Ok::<_, Infallible>(service_fn(handle))
    });

    let server = Server::bind(&addr).serve(make_svc);

    if let Err(e) = server.await {
        eprintln!("server error: {}", e);
    }
}

async fn handle(req: Request<Body>) -> http::Result<Response<Body>> {
    println!("Request: {:#?}", req);

    let mut parts = req.uri().path().split('/').filter(|p| p.len() > 0);
    let mut response: Option<http::Result<Response<Body>>> = None;

    match parts.next() {
        Some("hello") => {
            if let Some(number) = parts.next() {
                if let Some(name) = parts.next() {
                    if let None = parts.next() { // ensure it was the last part of the path
                        response = Some(handle_hello(&req, number, name).await);
                    }
                }
            }
        }
        Some("bonjour") => {
            if let Some(first_part) = parts.next() {
                if let Some(second_part) = parts.next() {
                    response = Some(handle_bonjour(Some(first_part), second_part));
                } else {
                    response = Some(handle_bonjour(None, first_part).await);
                }
            }
        }
        _ => {}
    };

    response.unwrap_or_else(|| {
        Response::builder()
            .status(StatusCode::NOT_FOUND)
            .body(Body::from(format!("Nothing found at {}", req.uri().path())))
    })
}

async fn handle_hello(req: &Request<Body>, number: &str, name: &str) -> http::Result<Response<Body>> {
    let number: u32 = match number.parse() {
        Ok(n) => n,
        Err(_) => {
            return Response::builder()
                .status(StatusCode::BAD_REQUEST)
                .header("x-you-failed", "oh so much")
                .body(Body::from(format!("/hello/number/name : number needs to be an unsigned 32-bit integer value")));
        }
    };

    let user_agent: &str = req.headers().get("User-Agent")
        .and_then(|v| v.to_str().ok())
        .unwrap_or("<unspecified>");

    Response::builder()
        .status(StatusCode::OK)
        .body(Body::from(format!("Hello, number {}: {} from {}", number, name, user_agent)))
}

async fn handle_bonjour(title: Option<&str>, name: &str) -> http::Result<Response<Body>> {
    Response::builder()
        .status(StatusCode::OK)
        .body(Body::from(match title {
            Some(title) => format!("Bonjour, {} {}", title, name),
            None => format!("Bonjour, {}", name),
        }))
}
