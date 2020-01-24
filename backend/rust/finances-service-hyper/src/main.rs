use std::convert::Infallible;
use std::error::Error;
use std::net::SocketAddr;

use hyper::{Body, Request, Response, Server, StatusCode};
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

async fn handle(req: Request<Body>) -> Result<Response<Body>, Infallible> {
    println!("Request: {:#?}", req);

    let mut path_parts = req.uri().path().split('/');

    let mut response: Option<Result<Response<Body>, dyn Error>> = None;

    match path_parts.next() {
        Some("hello") => {
            if let (Some(number), Some(name)) = (path_parts.next(), path_parts.next()) {
                response = Some(handle_hello(&req, number, name));
            }
        }
        Some("bonjour") => { /* TODO */ }
        _ => { /* NOOP */ }
    };

//    response
//        .unwrap(|| {
//            Response::builder()
//                .status(hyper::StatusCode::NOT_FOUND)
//                .body(Body::from(format!("Path {} not found.", req.uri())))
//        })

    Ok(Response::builder().status(StatusCode::OK).body(Body::from(format!("Hello!"))).unwrap())
}

fn handle_hello(req: &Request<Body>, number: &str, name: &str) -> Result<Response<Body>, dyn Error> {
//    let number: u32 = match number.parse() {
//        Ok(n) => n,
//        Err(_) => {
//            return Response::builder()
//                .status(StatusCode::BAD_REQUEST)
//                .header("x-you-suck", "true")
//                .body(Body::from(format!("/hello/number/name : number needs to be an unsigned 32-bit integer value")))
//        }
//    };
//
//    let user_agent = req.headers().get("User-Agent").unwrap_or_else("");
//

    Response::builder()
        .body(Body::from(format!("Hello, number {}: {} from {}", number, name)))
}
