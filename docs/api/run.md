# Run code api examples with rce-images

## Run code

### Request

```bash
curl --request POST \
     --header 'X-Access-Token: some-secret-token' \
     --header 'Content-type: application/json' \
     --data '{"image": "toolkithub/python:edge", "payload": {"language": "python", "files": [{"name": "main.py", "content": "print(42)"}]}}' \
     --url 'http://<rce-engine>/run'
```

### Response

```json
{
  "stdout": "42\n",
  "stderr": "",
  "error": ""
}
```

## Read data from stdin

### Request

```bash
curl --request POST \
     --header 'X-Access-Token: some-secret-token' \
     --header 'Content-type: application/json' \
     --data '{"image": "toolkithub/python:edge", "payload": {"language": "python", "stdin": "42", "files": [{"name": "main.py", "content": "print(input(\"Number from stdin: \"))"}]}}' \
     --url 'http://<rce-engine>/run'
```

### Response

```json
{
  "stdout": "Number from stdin: 42\n",
  "stderr": "",
  "error": ""
}
```

## Custom run command

### Request

```bash
curl --request POST \
     --header 'X-Access-Token: some-secret-token' \
     --header 'Content-type: application/json' \
     --data '{"image": "toolkithub/bash:edge", "payload": {"language": "bash", "command": "bash main.sh 42", "files": [{"name": "main.sh", "content": "echo Number from arg: $1"}]}}' \
     --url 'http://<rce-engine>/run'
```

### Response

```json
{
  "stdout": "Number from arg: 42\n",
  "stderr": "",
  "error": ""
}
```
