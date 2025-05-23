# rce-engine

**rce-engine** is a secure service for running untrusted code inside isolated Docker containers via a simple HTTP API. Execute code in 41 different programming languages with strong security guarantees.

[View full documentation](DOCUMENTATION.md)

## Why Use rce-engine?

- **Security First**: Run untrusted code safely in isolated containers
- **Language Support**: Execute code in 41 programming languages
- **Simple API**: Easy integration with a straightforward REST API
- **Fast Execution**: Optimized container startup (250-2200ms)
- **Resource Control**: Configure memory, CPU, and execution time limits

## Quick Start

**Requirements**:
- Ubuntu 22.04+
- Docker installed

### Installation

For installation instructions, see:
- [Standard Installation Guide](docs/install/ubuntu-22.04.md) (recommended)
- [Enhanced Security Installation with gVisor](docs/install/ubuntu-22.04-gvisor.md)

### Basic Usage

Run a Python program:

```bash
curl --request POST \
     --header 'X-Access-Token: your-token-here' \
     --header 'Content-Type: application/json' \
     --data '{
       "image": "toolkithub/python:edge", 
       "payload": {
         "language": "python", 
         "files": [{"name": "main.py", "content": "print(\"Hello world!\")"}]
       }
     }' \
     --url 'http://localhost:8080/run'
```

Response:
```json
{
  "stdout": "Hello world!\n",
  "stderr": "",
  "error": ""
}
```

## Supported Languages

rce-engine currently supports these 41 programming languages:

| Languages A-G | Languages G-N | Languages O-Z |
|---------------|---------------|---------------|
| Assembly      | Go            | OCaml         |
| ATS           | Groovy        | Perl          |
| Bash          | Haskell       | PHP           |
| C             | Idris         | Python        |
| C++           | Java          | Raku          |
| C#            | JavaScript    | Ruby          |
| Clojure       | Julia         | Rust          |
| COBOL         | Kotlin        | Scala         |
| CoffeeScript  | Lua           | Swift         |
| Crystal       | Mercury       | TypeScript    |
| D             | Nim           |               |
| Dart          |               |               |
| Elixir        |               |               |
| Elm           |               |               |
| Erlang        |               |               |
| F#            |               |               |

Don't see your language? [Open an issue](https://github.com/toolkithub/rce-engine/issues) and we'll consider adding it. New language support is continuously being added based on user demand.

## Documentation

- [Full documentation](DOCUMENTATION.md)
- [API Reference](docs/api/run.md)
- [Installation guides](docs/install/)

## Security

rce-engine is designed with security in mind:
- Fresh container for each execution
- Container destroyed after completion
- Resource limits to prevent abuse
- Optional gVisor runtime for enhanced isolation

## License

[See License](./LICENSE)
