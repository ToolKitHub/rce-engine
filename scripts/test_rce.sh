#!/bin/bash

BASE_URL="$1"
ACCESS_TOKEN="$2"

run() {
    RCE_IMAGE=$1
    PAYLOAD_PATH=$2

    JSON="{ \"image\": \"${RCE_IMAGE}\", \"payload\": $(cat "${PAYLOAD_PATH}") }"

    RUN_RESULT=$(curl \
        -X POST \
        -H "Content-type: application/json" \
        -H "X-Access-Token: ${ACCESS_TOKEN}" \
        --silent \
        --data "${JSON}" \
        --url "${BASE_URL}/run")

    echo "${RCE_IMAGE} [${PAYLOAD_PATH}]: ${RUN_RESULT}"
}

run "toolkithub/assembly:edge" "payload/assembly.json"
run "toolkithub/ats:edge" "payload/ats.json"
run "toolkithub/bash:edge" "payload/bash.json"
run "toolkithub/clang:edge" "payload/c.json"
run "toolkithub/clang:edge" "payload/cpp.json"
run "toolkithub/clojure:edge" "payload/clojure.json"
run "toolkithub/cobol:edge" "payload/cobol.json"
run "toolkithub/coffeescript:edge" "payload/coffeescript.json"
run "toolkithub/crystal:edge" "payload/crystal.json"
run "toolkithub/dlang:edge" "payload/dlang.json"
run "toolkithub/dart:edge" "payload/dart.json"
run "toolkithub/elixir:edge" "payload/elixir.json"
run "toolkithub/elm:edge" "payload/elm.json"
run "toolkithub/erlang:edge" "payload/erlang.json"
run "toolkithub/golang:edge" "payload/golang.json"
run "toolkithub/groovy:edge" "payload/groovy.json"
run "toolkithub/haskell:edge" "payload/haskell.json"
run "toolkithub/idris:edge" "payload/idris.json"
run "toolkithub/java:edge" "payload/java.json"
run "toolkithub/javascript:edge" "scripts/payload/javascript.json"
run "toolkithub/julia:edge" "payload/julia.json"
run "toolkithub/kotlin:edge" "payload/kotlin.json"
run "toolkithub/lua:edge" "payload/lua.json"
run "toolkithub/mercury:edge" "payload/mercury.json"
run "toolkithub/csharp:edge" "payload/csharp.json"
run "toolkithub/fsharp:edge" "payload/fsharp.json"
run "toolkithub/nim:edge" "payload/nim.json"
run "toolkithub/ocaml:edge" "payload/ocaml.json"
run "toolkithub/perl:edge" "payload/perl.json"
run "toolkithub/php:edge" "payload/php.json"
run "toolkithub/python:edge" "payload/python.json"
run "toolkithub/raku:edge" "payload/raku.json"
run "toolkithub/ruby:edge" "payload/ruby.json"
run "toolkithub/rust:edge" "payload/rust.json"
run "toolkithub/scala:edge" "payload/scala.json"
run "toolkithub/swift:edge" "payload/swift.json"
run "toolkithub/typescript:edge" "payload/typescript.json"
