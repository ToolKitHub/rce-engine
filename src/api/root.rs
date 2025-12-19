use serde::Serialize;

use crate::api;

const VERSION: &str = env!("CARGO_PKG_VERSION");

#[derive(Debug, Serialize)]
struct ServiceInfo {
    name: &'static str,
    version: &'static str,
    description: &'static str,
}

pub fn handle() -> Result<api::SuccessResponse, api::ErrorResponse> {
    let service_info = ServiceInfo {
        name: "rce-engine",
        version: VERSION,
        description: "HTTP API for running untrusted code inside isolated Docker containers",
    };

    api::prepare_json_response(&service_info, &api::JsonFormat::Pretty)
}
