# rce-engine API Reference

The `/run` endpoint is the core of the rce-engine API, allowing you to execute code in isolated Docker containers.

## API Endpoint

- **URL**: `/run`
- **Method**: `POST`
- **Required Headers**: 
  - `X-Access-Token`: Your API access token (set in server configuration)
  - `Content-Type`: `application/json`

## Request Format

```json
{
  "image": "toolkithub/<language>:latest",
  "payload": {
    "language": "<language>",
    "files": [
      {
        "name": "main.<ext>",
        "content": "your code here"
      },
      {
        "name": "another_file.<ext>",
        "content": "more code here"
      }
    ],
    "stdin": "optional input data",
    "command": "optional custom command"
  }
}
```

| Field | Type | Description | Required |
|-------|------|-------------|----------|
| `image` | string | The Docker image to use for execution | Yes |
| `payload.language` | string | Programming language identifier | Yes |
| `payload.files` | array | Array of file objects with name and content | Yes |
| `payload.stdin` | string | Data to provide to the program via stdin | No |
| `payload.command` | string | Custom command to run (overrides default) | No |

## Response Format

```json
{
  "stdout": "Standard output from program",
  "stderr": "Standard error output (if any)",
  "error": "Error message from the container (if any)"
}
```

## Examples

### 1. Basic Code Execution

Run a simple Python program:

#### Request

```bash
curl --request POST \
     --header 'X-Access-Token: your-token-here' \
     --header 'Content-type: application/json' \
     --data '{
       "image": "toolkithub/python:latest", 
       "payload": {
         "language": "python", 
         "files": [{"name": "main.py", "content": "print(42)"}]
       }
     }' \
     --url 'http://localhost:8080/run'
```

#### Response

```json
{
  "stdout": "42\n",
  "stderr": "",
  "error": ""
}
```

### 2. Reading from Standard Input

Process user input in Python:

#### Request

```bash
curl --request POST \
     --header 'X-Access-Token: your-token-here' \
     --header 'Content-type: application/json' \
     --data '{
       "image": "toolkithub/python:latest", 
       "payload": {
         "language": "python",
         "stdin": "42", 
         "files": [{"name": "main.py", "content": "print(input(\"Number from stdin: \"))"}]
       }
     }' \
     --url 'http://localhost:8080/run'
```

#### Response

```json
{
  "stdout": "Number from stdin: 42\n",
  "stderr": "",
  "error": ""
}
```

### 3. Custom Command with Arguments

Use a custom command to pass arguments to a bash script:

#### Request

```bash
curl --request POST \
     --header 'X-Access-Token: your-token-here' \
     --header 'Content-type: application/json' \
     --data '{
       "image": "toolkithub/bash:latest", 
       "payload": {
         "language": "bash",
         "command": "bash main.sh 42", 
         "files": [{"name": "main.sh", "content": "echo Number from arg: $1"}]
       }
     }' \
     --url 'http://localhost:8080/run'
```

#### Response

```json
{
  "stdout": "Number from arg: 42\n",
  "stderr": "",
  "error": ""
}
```

### 4. Multiple Files

Working with multiple files in a C++ project:

#### Request

```bash
curl --request POST \
     --header 'X-Access-Token: your-token-here' \
     --header 'Content-type: application/json' \
     --data '{
       "image": "toolkithub/clang:latest", 
       "payload": {
         "language": "cpp",
         "files": [
           {
             "name": "main.cpp",
             "content": "#include \"utils.h\"\n\nint main() {\n  printMessage();\n  return 0;\n}"
           },
           {
             "name": "utils.h",
             "content": "#include <iostream>\n\nvoid printMessage();"
           },
           {
             "name": "utils.cpp",
             "content": "#include \"utils.h\"\n\nvoid printMessage() {\n  std::cout << \"Hello from utils!\" << std::endl;\n}"
           }
         ]
       }
     }' \
     --url 'http://localhost:8080/run'
```

#### Response

```json
{
  "stdout": "Hello from utils!\n",
  "stderr": "",
  "error": ""
}
```

## Error Handling

When errors occur, they'll be returned in the appropriate field:

```json
{
  "stdout": "",
  "stderr": "main.py:1: SyntaxError: invalid syntax\n",
  "error": "Process exited with status 1"
}
```

## Resource Limits

All code execution is subject to the resource limits configured on the server:

- **Execution Time**: Limited by `RUN_MAX_EXECUTION_TIME` (seconds)
- **Output Size**: Limited by `RUN_MAX_OUTPUT_SIZE` (bytes)
- **Memory Usage**: Limited by `DOCKER_CONTAINER_MEMORY` (bytes)
- **Process Count**: Limited by `DOCKER_CONTAINER_ULIMIT_NPROC_HARD`

If your program exceeds these limits, execution will be terminated and an appropriate error will be returned.
