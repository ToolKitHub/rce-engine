#!/bin/bash
# RCE engine test script - Run code in multiple language containers
set -eo pipefail

# Validate args
[[ $# -ne 2 ]] && { echo "Usage: $0 <base_url> <access_token>"; exit 1; }

BASE_URL="$1"
ACCESS_TOKEN="$2"
PAYLOAD_DIR="$(dirname "$0")/payload"

# Test languages
run_test() {
    local payload_file="${PAYLOAD_DIR}/${2}.json"
    [[ ! -f "$payload_file" ]] && { echo "Error: $payload_file not found"; return 1; }
    
    echo "Testing $2..."
    local json="{\"image\":\"toolkithub/${1}:edge\",\"payload\":$(cat "${payload_file}")}"
    local response=$(curl -X POST \
        -H "Content-type: application/json" \
        -H "X-Access-Token: ${ACCESS_TOKEN}" \
        --silent \
        --data "${json}" \
        --url "${BASE_URL}/run")
    echo "  Result: ${response}"
    echo
}

# Language definitions - format: "image:payload_name"
LANGS=(
    "assembly:assembly" "ats:ats" "bash:bash" "clang:c" "clang:cpp"
    "clojure:clojure" "cobol:cobol" "coffeescript:coffeescript" 
    "crystal:crystal" "dlang:dlang" "dart:dart" "elixir:elixir" 
    "elm:elm" "erlang:erlang" "golang:golang" "groovy:groovy" 
    "haskell:haskell" "idris:idris" "java:java" "javascript:javascript" 
    "julia:julia" "kotlin:kotlin" "lua:lua" "mercury:mercury" 
    "csharp:csharp" "fsharp:fsharp" "nim:nim" "ocaml:ocaml" 
    "perl:perl" "php:php" "python:python" "raku:raku" 
    "ruby:ruby" "rust:rust" "scala:scala" "swift:swift" 
    "typescript:typescript"
)

echo "Starting tests against ${BASE_URL}"
echo "--------------------------------"

# Run all tests
for lang in "${LANGS[@]}"; do
    run_test ${lang%:*} ${lang#*:}
done

echo "All tests complete!"
