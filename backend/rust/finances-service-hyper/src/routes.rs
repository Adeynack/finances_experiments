use hyper::{Body, Method, Request, Response, StatusCode};
use regex::{Regex, Captures};

use crate::routes::RouteCreationError::{PathRegExError, RouteAlreadyExist};

type Req = Request<Body>;
type Resp = hyper::http::Result<Response<Body>>;
type Handler = fn(Req, Captures) -> Resp;

struct Route {
    matcher: Regex,
    method: Method,
    handler: Handler,
}

pub struct Router {
    routes: Vec<Route>,
}

impl Router {
    pub fn new() -> Router {
        Router {
            routes: vec![]
        }
    }

    pub fn route(&mut self, method: Method, path_exp: &str, handler: Handler) -> Result<(), RouteCreationError> {
        // create regular expression to match this route
        let matcher = Regex::new(path_exp).map_err(PathRegExError)?;
        // make sure another route does not already match this
        for route in &self.routes {
            if route.matcher.as_str() == matcher.as_str() {
                return Err(RouteAlreadyExist(route.matcher.to_string()));
            }
        }
        // add the route to the router
        self.routes.push(Route { matcher, method, handler });
        Ok(())
    }

    pub async fn handle(&self, req: Req) -> Resp {
        let path = req.uri().path().to_string();
        println!("Router received request {} {}", req.method(), path);
        // todo: match also on the request's METHOD (GET, POST, ...)
        let routes_for_method = self.routes.iter().filter(|r| r.method == req.method());
        for route in routes_for_method {
            if let Some(captures) = route.matcher.captures(&path) {
                return (route.handler)(req, captures);
            }
        }
        Response::builder()
            .status(StatusCode::NOT_FOUND)
            .body(Body::from("Not found"))

//        match self.routes.iter().find_map(|route| {
//            route.matcher.captures(&path).map(|captures| { (route, captures) })
//        }) {
//            None => Response::builder()
//                .status(StatusCode::NOT_FOUND)
//                .body(Body::from("Not found")),
//            Some((route, captures)) => {
//                if captures.len() > 1 {
//                    println!("WARN: Group captured more than once.")
//                }
//                (route.handler)(req, captures.get(0).unwrap())
//            }
//        }
    }
}

#[derive(Debug)]
pub enum RouteCreationError {
    PathRegExError(regex::Error),
    RouteAlreadyExist(String),
}
