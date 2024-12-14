use serde::Serialize;

use crate::rce_engine::api;

const VERSION: &str = env!("CARGO_PKG_VERSION");

#[derive(Debug, Serialize)]
struct ServiceInfo {
    name: String,
    version: String,
    description: String,
}

pub fn handle() -> Result<api::SuccessResponse, api::ErrorResponse> {
    let service_info = ServiceInfo {
        name: "rce-engine".to_string(),
        version: VERSION.to_string(),
        description: "Docker-based engine for executing untrusted code in isolated containers."
            .to_string(),
    };

    api::prepare_json_response(&service_info, api::JsonFormat::Pretty)
}
