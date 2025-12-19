use crate::{api, debug, run, unix_stream};

pub struct Config {
    pub server: ServerConfig,
    pub api: api::ApiConfig,
    pub unix_socket: unix_stream::Config,
    pub container: run::ContainerConfig,
    pub run: run::Limits,
    pub debug: debug::Config,
}

#[derive(Clone, Debug)]
pub struct ServerConfig {
    pub listen_addr: String,
    pub listen_port: u16,
    pub worker_threads: usize,
}
