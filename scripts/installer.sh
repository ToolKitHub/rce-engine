#!/usr/bin/env bash

# This program will:
# 1. Update system packages and install dependencies (docker.io, runsc, certificates)
# 2. Install and configure gVisor as a secure container runtime
# 3. Configure Docker with security-focused settings (networking disabled)
# 4. Create dedicated 'rce' user and add to docker group
# 5. Download and install rce-engine binary (v1.2.5)
# 6. Set up systemd service with API token authentication
# 7. Enable and start the rce-engine service
# 8. Present menu for installing supported programming languages (41 languages)
# 9. Download selected language Docker images in parallel
# 10. Verify installation and confirm completion

set -e

STATE_FILE="/home/rce/.rce-engine-install-state"

mark_step_complete() {
	local step=$1
	sudo mkdir -p "$(dirname "$STATE_FILE")"
	sudo touch "$STATE_FILE"
	if ! grep -q "^${step}$" "$STATE_FILE" 2>/dev/null; then
		echo "$step" | sudo tee -a "$STATE_FILE" >/dev/null
	fi
}

is_step_complete() {
	local step=$1
	[[ -f "$STATE_FILE" ]] && grep -q "^${step}$" "$STATE_FILE" 2>/dev/null
}

CONFIG_CHANGED=false

log() {
	echo -e "\033[1;34m[INFO]\033[0m $1"
}

error() {
	echo -e "\033[1;31m[ERROR]\033[0m $1" >&2
}

prompt_yes_no() {
	while true; do
		read -r -p "$1 [y/N] " response
		case "$response" in
		[yY][eE][sS] | [yY]) return 0 ;;
		[nN][oO] | [nN] | "") return 1 ;;
		*) echo "Please answer yes or no." ;;
		esac
	done
}

check_requirements() {
	log "Checking system requirements..."

	if ! grep -q "Ubuntu" /etc/os-release; then
		error "This script requires Ubuntu 22.04 or newer"
		return 1
	fi

	total_mem=$(free -m | awk '/^Mem:/{print $2}')
	if [ "$total_mem" -lt 2048 ]; then
		error "Minimum 2GB RAM required (found: ${total_mem}MB)"
		return 1
	fi

	free_space=$(df -m / | awk 'NR==2 {print $4}')
	if [ "$free_space" -lt 20480 ]; then
		error "Minimum 20GB free disk space required (found: ${free_space}MB)"
		return 1
	fi

	if netstat -tuln | grep -q ":8080 "; then
		error "Port 8080 is already in use"
		return 1
	fi

	return 0
}

echo -e "\n\033[1;32mrce-engine installer\033[0m\n"
echo "This program will:"
echo -e "\033[37m"
sed -n '/^# [0-9]/p' "$0" | sed 's/# //'
echo -e "\033[0m"

if ! prompt_yes_no "Would you like to proceed with the installation?"; then
	log "Installation cancelled by user"
	exit 0
fi

if ! check_requirements; then
	error "System requirements not met. Please fix the issues above and try again."
	exit 1
fi

log "All system requirements met. Starting installation..."

if ! prompt_yes_no "Ready to begin installation. Continue?"; then
	log "Installation cancelled by user"
	exit 0
fi

if ! is_step_complete "packages_updated"; then
	log "Updating package list..."
	sudo apt update
	mark_step_complete "packages_updated"
fi

pkgs=("docker.io" "runsc" "apt-transport-https" "ca-certificates" "gnupg-agent" "software-properties-common")

for pkg in "${pkgs[@]}"; do
	if ! dpkg -l | grep -q "^ii  ${pkg}"; then
		log "Installing ${pkg}..."
		sudo apt-get install -y "${pkg}" || error "Failed to install ${pkg}"
	else
		log "Package ${pkg} is already installed"
	fi
done

if ! grep -q "gvisor" /etc/apt/sources.list /etc/apt/sources.list.d/* 2>/dev/null; then
	log "Adding gVisor repository..."
	curl -fsSL https://gvisor.dev/archive.key | sudo apt-key add - || error "Failed to add gVisor key"
	sudo add-apt-repository "deb https://storage.googleapis.com/gvisor/releases release main" || error "Failed to add gVisor repository"
	sudo apt update
else
	log "gVisor repository already added"
fi

if ! dpkg -l | grep -q "^ii  runsc"; then
	log "Installing gVisor..."
	sudo apt-get install -y runsc || error "Failed to install runsc"
else
	log "gVisor (runsc) is already installed"
fi

docker_config_changed=false
if [[ -f /etc/docker/daemon.json ]]; then
	current_config=$(cat /etc/docker/daemon.json)
	if [[ "$current_config" == *"runsc"* && "$current_config" == *"default-runtime"* ]]; then
		log "Docker is already configured with gVisor/runsc"
	else
		log "Updating Docker configuration..."
		docker_config_changed=true
	fi
else
	log "Configuring Docker..."
	docker_config_changed=true
fi

if [[ "$docker_config_changed" == true ]]; then
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

	log "Restarting Docker service..."
	sudo systemctl restart docker.service || error "Failed to restart Docker service"
	CONFIG_CHANGED=true
	mark_step_complete "docker_configured"
fi

if ! id "rce" &>/dev/null; then
	log "Creating user for rce-engine..."
	sudo useradd -m rce || error "Failed to create user rce"
	mark_step_complete "user_created"
else
	log "User 'rce' already exists"
fi

if ! groups rce | grep -q "docker"; then
	log "Adding user 'rce' to docker group..."
	sudo usermod -aG docker rce || error "Failed to add user rce to docker group"
	mark_step_complete "user_added_to_docker"
else
	log "User 'rce' is already in docker group"
fi

if [[ -f /home/rce/bin/rce-engine && -x /home/rce/bin/rce-engine ]]; then
	installed_version=$(/home/rce/bin/rce-engine --version 2>/dev/null || echo "unknown")
	if [[ "$installed_version" == *"v1.2.5"* ]]; then
		log "rce-engine v1.2.5 is already installed"
	else
		log "Updating rce-engine binary..."
		sudo mkdir -p /home/rce/bin
		cd /home/rce/bin

		log "Downloading rce-engine binary..."
		curl -LO https://github.com/toolkithub/rce-engine/releases/download/v1.2.5/rce-engine_linux-x64.tar.gz || error "Failed to download rce-engine binary"

		log "Extracting rce-engine binary..."
		sudo tar -zxf rce-engine_linux-x64.tar.gz || error "Failed to extract rce-engine binary"
		rm rce-engine_linux-x64.tar.gz
		sudo chown -R rce:rce /home/rce/bin || error "Failed to change ownership of rce-engine binary"
		mark_step_complete "rce_engine_installed"
		CONFIG_CHANGED=true
	fi
else
	log "Installing rce-engine binary..."
	sudo mkdir -p /home/rce/bin
	cd /home/rce/bin

	log "Downloading rce-engine binary..."
	curl -LO https://github.com/toolkithub/rce-engine/releases/download/v1.2.5/rce-engine_linux-x64.tar.gz || error "Failed to download rce-engine binary"

	log "Extracting rce-engine binary..."
	sudo tar -zxf rce-engine_linux-x64.tar.gz || error "Failed to extract rce-engine binary"
	rm rce-engine_linux-x64.tar.gz
	sudo chown -R rce:rce /home/rce/bin || error "Failed to change ownership of rce-engine binary"
	mark_step_complete "rce_engine_installed"
	CONFIG_CHANGED=true
fi

if [[ -f /etc/systemd/system/rce-engine.service ]]; then
	current_token=$(grep "API_ACCESS_TOKEN" /etc/systemd/system/rce-engine.service | cut -d '=' -f 2 | tr -d '"')

	if [[ -n "$current_token" && "$current_token" != "some-secret-token" ]]; then
		log "rce-engine service is already configured with an API token"
		api_access_token="$current_token"
	else
		log "Updating rce-engine service configuration..."
		read -r -p "Enter an API access token you'd like to use for rce-engine X-Access-Token Header: " api_access_token
		sudo sed -i "s/Environment=\"API_ACCESS_TOKEN=some-secret-token\"/Environment=\"API_ACCESS_TOKEN=${api_access_token}\"/" /etc/systemd/system/rce-engine.service || error "Failed to update rce-engine.service with API access token"
		CONFIG_CHANGED=true
	fi
else
	log "Configuring rce-engine systemd service..."
	curl -o /etc/systemd/system/rce-engine.service https://raw.githubusercontent.com/toolkithub/rce-engine/main/systemd/rce-engine.service || error "Failed to download rce-engine systemd service file"

	read -r -p "Enter an API access token you'd like to use for rce-engine X-Access-Token Header: " api_access_token
	sudo sed -i "s/Environment=\"API_ACCESS_TOKEN=some-secret-token\"/Environment=\"API_ACCESS_TOKEN=${api_access_token}\"/" /etc/systemd/system/rce-engine.service || error "Failed to update rce-engine.service with API access token"
	CONFIG_CHANGED=true
	mark_step_complete "service_configured"
fi

if [[ "$CONFIG_CHANGED" = true ]]; then
	log "Reloading systemd daemon..."
	sudo systemctl daemon-reload || error "Failed to reload systemd"
fi

if ! systemctl is-enabled rce-engine.service &>/dev/null; then
	log "Enabling rce-engine service..."
	sudo systemctl enable rce-engine.service || error "Failed to enable rce-engine service"
	mark_step_complete "service_enabled"
else
	log "rce-engine service is already enabled"
fi

if ! systemctl is-active rce-engine.service &>/dev/null; then
	log "Starting rce-engine service..."
	sudo systemctl start rce-engine.service || error "Failed to start rce-engine service"
	mark_step_complete "service_started"
else
	if [[ "$CONFIG_CHANGED" = true ]]; then
		log "Restarting rce-engine service..."
		sudo systemctl restart rce-engine.service || error "Failed to restart rce-engine service"
	else
		log "rce-engine service is already running"
	fi
fi

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

convert_to_lowercase() {
	echo "${1}" | tr '[:upper:]' '[:lower:]'
}

trim_whitespace() {
	echo "${1}" | tr -d '[:space:]'
}

pull_language_image() {
	local language=$1
	local image_name="toolkithub/$(convert_to_lowercase "${language}"):edge"

	if docker image inspect "$image_name" &>/dev/null; then
		log "Image for ${language} already exists, skipping pull"
		return 0
	else
		log "Pulling image for ${language}..."
		if ! docker pull "$image_name"; then
			error "Failed to pull image for ${language}"
			return 1
		fi
	fi
}

main() {
	display_supported_languages

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

mark_step_complete "installation_completed"
