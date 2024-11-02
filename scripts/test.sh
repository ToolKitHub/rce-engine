#!/bin/bash

if [[ $# -ne 2 ]]; then
	echo "Usage: $0 <base_url> <access_token>"
	exit 1
fi

BASE_URL="$1"
ACCESS_TOKEN="$2"

run() {
	local image=$1
	local payload=$2
	local json="{\"image\":\"${image}\",\"payload\":$(cat "${payload}")}"

	local result=$(curl -X POST \
		-H "Content-type: application/json" \
		-H "X-Access-Token: ${ACCESS_TOKEN}" \
		--silent \
		--data "${json}" \
		--url "${BASE_URL}/run")

	echo "${image} [${payload}]: ${result}"
}

TESTS=(
	"assembly:assembly"
	"ats:ats"
	"bash:bash"
	"clang:c"
	"clang:cpp"
	"clojure:clojure"
	"cobol:cobol"
	"coffeescript:coffeescript"
	"crystal:crystal"
	"dlang:dlang"
	"dart:dart"
	"elixir:elixir"
	"elm:elm"
	"erlang:erlang"
	"golang:golang"
	"groovy:groovy"
	"haskell:haskell"
	"idris:idris"
	"java:java"
	"javascript:javascript"
	"julia:julia"
	"kotlin:kotlin"
	"lua:lua"
	"mercury:mercury"
	"csharp:csharp"
	"fsharp:fsharp"
	"nim:nim"
	"ocaml:ocaml"
	"perl:perl"
	"php:php"
	"python:python"
	"raku:raku"
	"ruby:ruby"
	"rust:rust"
	"scala:scala"
	"swift:swift"
	"typescript:typescript"
)

for test in "${TESTS[@]}"; do
	image=${test%:*}
	payload=${test#*:}
	run "toolkithub/${image}:edge" "payload/${payload}.json"
done
