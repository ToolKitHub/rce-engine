#!/usr/bin/env bash

set -e

# Function to log messages
log() {
	echo -e "\033[1;34m[INFO]\033[0m $1"
}

# Function to log errors
error() {
	echo -e "\033[1;31m[ERROR]\033[0m $1" >&2
}

# Update package list
log "Updating package list..."
sudo apt update

# Check for essential packages needed for the installation like curl, docker, etc. If they are not installed, install them.
pkgs=("docker.io" "runsc" "apt-transport-https" "ca-certificates" "gnupg-agent" "software-properties-common")

for pkg in "${pkgs[@]}"; do
	if ! dpkg -l | grep -q "^ii  ${pkg}"; then
		log "Installing ${pkg}..."
		sudo apt-get install -y "${pkg}" || error "Failed to install ${pkg}"
	fi
done

# Install gVisor
log "Installing gVisor..."
curl -fsSL https://gvisor.dev/archive.key | sudo apt-key add - || error "Failed to add gVisor key"
sudo add-apt-repository "deb https://storage.googleapis.com/gvisor/releases release main" || error "Failed to add gVisor repository"
sudo apt update
sudo apt-get install -y runsc || error "Failed to install runsc"

# Configure gVisor and disable Docker networking
log "Configuring gVisor and Docker..."
cat <<EOF | sudo tee /etc/docker/daemon.json
{
    "iptables": false,
    "ip-masq": false,
    "ip-forward": false,
    "ipv6": false,
    "default-runtime": "runsc",
    "runtimes": {
        "runsc": {
            "path": "/usr/bin/runsc"
        }
    }
}
EOF

# Restart Docker service
log "Restarting Docker service..."
sudo systemctl restart docker.service || error "Failed to restart Docker service"

# Create user for rce-engine
log "Creating user for rce-engine..."
sudo useradd -m rce || error "Failed to create user rce"
sudo usermod -aG docker rce || error "Failed to add user rce to docker group"

# Install rce-engine binary
log "Installing rce-engine binary..."
sudo mkdir -p /home/rce/bin
cd /home/rce/bin

log "Downloading rce-engine binary..."
curl -LO https://github.com/toolkithub/rce-engine/releases/download/v1.2.4/rce-engine_linux-x64.tar.gz || error "Failed to download rce-engine binary"

log "Extracting rce-engine binary..."
sudo tar -zxf rce-engine_linux-x64.tar.gz || error "Failed to extract rce-engine binary"
rm rce-engine_linux-x64.tar.gz
sudo chown -R rce:rce /home/rce/bin || error "Failed to change ownership of rce-engine binary"

# Configure rce-engine systemd service
log "Configuring rce-engine systemd service..."
curl -o /etc/systemd/system/rce-engine.service https://raw.githubusercontent.com/toolkithub/rce-engine/main/systemd/rce-engine.service || error "Failed to download rce-engine systemd service file"

# Prompt user to set the API access token
read -r -p "Enter an API access token you'd like to use for rce-engine X-Access-Token Header: " api_access_token

# Update rce-engine.service with the API access token
sudo sed -i "s/Environment=\"API_ACCESS_TOKEN=some-secret-token\"/Environment=\"API_ACCESS_TOKEN=${api_access_token}\"/" /etc/systemd/system/rce-engine.service || error "Failed to update rce-engine.service with API access token"

# Reload systemd and start rce-engine service
log "Reloading systemd and starting rce-engine service..."
sudo systemctl daemon-reload || error "Failed to reload systemd"
sudo systemctl enable rce-engine.service || error "Failed to enable rce-engine service"
sudo systemctl start rce-engine.service || error "Failed to start rce-engine service"

# This phase of the script installs the rce-images for supported languages interactively.
# see https://github.com/toolkithub/rce-images
languages=(
	"Assembly"
	"Ats"
	"Bash"
	"Clang"
	"Clisp"
	"Clojure"
	"Cobol"
	"CoffeeScript"
	"Crystal"
	"Csharp"
	"Dlang"
	"Dart"
	"Elixir"
	"Elm"
	"Erlang"
	"Fsharp"
	"Golang"
	"Groovy"
	"Guile"
	"Hare"
	"Haskell"
	"Idris"
	"Java"
	"JavaScript"
	"Julia"
	"Kotlin"
	"Lua"
	"Mercury"
	"Nim"
	"Nix"
	"Ocaml"
	"Pascal"
	"Perl"
	"Php"
	"Python"
	"Raku"
	"Ruby"
	"Rust"
	"SaC"
	"Scala"
	"Swift"
	"TypeScript"
	"Zig"
)

# Display supported languages
display_supported_languages() {
	echo -e "\n\033[1;34mSupported Languages (select by number):\033[0m"
	for i in "${!languages[@]}"; do
		printf "\033[1;32m%2d.\033[0m \033[1;37m%-15s\033[0m" $((i + 1)) "${languages[${i}]}"
		if (((i + 1) % 6 == 0)); then
			echo
		fi
	done
	echo -e "\n"
}

# Convert string to lowercase
convert_to_lowercase() {
	echo "${1}" | tr '[:upper:]' '[:lower:]'
}

# Trim whitespace from a string
trim_whitespace() {
	echo "${1}" | tr -d '[:space:]'
}

# Pull Docker image for the given language
pull_language_image() {
	local language=$1
	log "Pulling image for ${language}..."
	if ! docker pull toolkithub/$(convert_to_lowercase "${language}"):edge; then
		error "Failed to pull image for ${language}"
		return 1
	fi
}

# Main function
main() {
	display_supported_languages

	# Prompt user input
	read -r -p "Enter the number corresponding to the language(s) you'd like to install (comma-separated), or press Enter to install all: " language_input
	language_input=$(trim_whitespace "${language_input}")

	is_valid_input=true
	if [[ -z ${language_input} ]]; then
		for language in "${languages[@]}"; do
			pull_language_image "${language}" &
		done
		wait
	else
		IFS=',' read -r -a indices <<<"${language_input}"
		is_valid_input=true

		for index in "${indices[@]}"; do
			if ! [[ ${index} =~ ^[0-9]+$ ]] || ((index < 1 || index > ${#languages[@]})); then
				error "Unsupported language index: ${index}"
				is_valid_input=false
				break
			fi
		done

		if [[ ${is_valid_input} == true ]]; then
			for index in "${indices[@]}"; do
				language="${languages[$((index - 1))]}"
				pull_language_image "${language}" &
			done
			wait
			log "Successfully pulled images for selected languages."
		else
			error "Invalid input. Please enter a valid number or a comma-separated list of numbers."
			main
		fi
	fi
}

main

log "Installation complete!"
