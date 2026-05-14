#!/usr/bin/env bash
###################
#
# Created by: Aviv
# Purpose: install and run the status-dashboard service
# Version: 0.0.1
# Date: 11.05.2026
#
###################
set -euo pipefail

NAME="status-dashboard"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSION="${VERSION:-1.0.0}"
API_KEY="${API_KEY:-}"

check_root() {
    if [[ "${EUID}" -ne 0 ]]; then
        echo "Error: install.sh must be run as root (use sudo)" >&2
        exit 1
    fi
}

check_api_key() {
    if [[ -z "${API_KEY}" ]]; then
        echo "Error: API_KEY environment variable is required" >&2
        echo "Usage: sudo API_KEY=<key> ./install.sh" >&2
        exit 1
    fi
}

build_image() {
    echo "Building image ${NAME}..."
    docker build -t "${NAME}" "${SCRIPT_DIR}"
}

stop_existing() {
    echo "Removing any existing container named ${NAME}..."
    docker rm -f "${NAME}" >/dev/null 2>&1 || true
}

run_container() {
    echo "Starting container ${NAME}"
    docker run -d \
        --name "${NAME}" \
        --restart unless-stopped \
        -p 127.0.0.1:5000:5000 \
        -e API_KEY="${API_KEY}" \
        -e VERSION="${VERSION}" \
        -e PORT=5000 \
        "${NAME}" >/dev/null
}

install_nginx_config() {
    echo "Installing nginx site config"
    cp "${SCRIPT_DIR}/status-dashboard.conf" "/etc/nginx/sites-available/${NAME}"
    ln -sf "/etc/nginx/sites-available/${NAME}" "/etc/nginx/sites-enabled/${NAME}"
    rm -f /etc/nginx/sites-enabled/default
    nginx -t
    systemctl enable nginx
    systemctl reload-or-restart nginx
}

print_success() {
    local host_ip
    host_ip="$(hostname -I | awk '{print $1}')"
    echo
    echo "status-dashboard is up at http://${host_ip:-localhost}/"
}

main() {
    check_root
    check_api_key
    build_image
    stop_existing
    run_container
    install_nginx_config
    print_success
}

main "$@"
