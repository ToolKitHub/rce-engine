use crate::rce_engine::api;

const VERSION: Option<&'static str> = option_env!("CARGO_PKG_VERSION");

#[derive(Debug, serde::Serialize)]
struct ServiceInfo {
    name: &'static str,
    version: &'static str,
    description: &'static str,
}

pub fn handle() -> Result<api::SuccessResponse, api::ErrorResponse> {
    let service_info = ServiceInfo {
        name: "rce-engine",
        version: VERSION.unwrap_or("unknown"),
        description: "Docker-based engine for executing untrusted code in isolated containers.",
    };

    api::prepare_json_response(&service_info, api::JsonFormat::Pretty)
}
