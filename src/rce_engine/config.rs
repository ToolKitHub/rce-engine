use crate::rce_engine::api;
use crate::rce_engine::debug;
use crate::rce_engine::run;
use crate::rce_engine::unix_stream;

#[derive(Clone, Debug)]
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
