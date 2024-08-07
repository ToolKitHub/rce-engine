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

run "ghcr.io/toolkithub/rce-images-assembly:edge" "payload/assembly.json"
run "ghcr.io/toolkithub/rce-images-ats:edge" "payload/ats.json"
run "ghcr.io/toolkithub/rce-images-bash:edge" "payload/bash.json"
run "ghcr.io/toolkithub/rce-images-clang:edge" "payload/c.json"
run "ghcr.io/toolkithub/rce-images-clang:edge" "payload/cpp.json"
run "ghcr.io/toolkithub/rce-images-clojure:edge" "payload/clojure.json"
run "ghcr.io/toolkithub/rce-images-cobol:edge" "payload/cobol.json"
run "ghcr.io/toolkithub/rce-images-coffeescript:edge" "payload/coffeescript.json"
run "ghcr.io/toolkithub/rce-images-crystal:edge" "payload/crystal.json"
run "ghcr.io/toolkithub/rce-images-dlang:edge" "payload/dlang.json"
run "ghcr.io/toolkithub/rce-images-dart:edge" "payload/dart.json"
run "ghcr.io/toolkithub/rce-images-elixir:edge" "payload/elixir.json"
run "ghcr.io/toolkithub/rce-images-elm:edge" "payload/elm.json"
run "ghcr.io/toolkithub/rce-images-erlang:edge" "payload/erlang.json"
run "ghcr.io/toolkithub/rce-images-golang:edge" "payload/golang.json"
run "ghcr.io/toolkithub/rce-images-groovy:edge" "payload/groovy.json"
run "ghcr.io/toolkithub/rce-images-haskell:edge" "payload/haskell.json"
run "ghcr.io/toolkithub/rce-images-idris:edge" "payload/idris.json"
run "ghcr.io/toolkithub/rce-images-java:edge" "payload/java.json"
run "ghcr.io/toolkithub/rce-images-javascript:edge" "payload/javascript.json"
run "ghcr.io/toolkithub/rce-images-julia:edge" "payload/julia.json"
run "ghcr.io/toolkithub/rce-images-kotlin:edge" "payload/kotlin.json"
run "ghcr.io/toolkithub/rce-images-lua:edge" "payload/lua.json"
run "ghcr.io/toolkithub/rce-images-mercury:edge" "payload/mercury.json"
run "ghcr.io/toolkithub/rce-images-csharp:edge" "payload/csharp.json"
run "ghcr.io/toolkithub/rce-images-fsharp:edge" "payload/fsharp.json"
run "ghcr.io/toolkithub/rce-images-nim:edge" "payload/nim.json"
run "ghcr.io/toolkithub/rce-images-ocaml:edge" "payload/ocaml.json"
run "ghcr.io/toolkithub/rce-images-perl:edge" "payload/perl.json"
run "ghcr.io/toolkithub/rce-images-php:edge" "payload/php.json"
run "ghcr.io/toolkithub/rce-images-python:edge" "payload/python.json"
run "ghcr.io/toolkithub/rce-images-raku:edge" "payload/raku.json"
run "ghcr.io/toolkithub/rce-images-ruby:edge" "payload/ruby.json"
run "ghcr.io/toolkithub/rce-images-rust:edge" "payload/rust.json"
run "ghcr.io/toolkithub/rce-images-scala:edge" "payload/scala.json"
run "ghcr.io/toolkithub/rce-images-swift:edge" "payload/swift.json"
run "ghcr.io/toolkithub/rce-images-typescript:edge" "payload/typescript.json"
