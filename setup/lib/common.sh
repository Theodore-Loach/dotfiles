#!/usr/bin/env bash
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
NC="\033[0m"
env_type=""
OPTIONAL_FAILURES=()
SETUP_TEMP_DIRS=()
SETUP_PARTIAL=false
SETUP_ENVIRONMENT=""
SETUP_ASSUME_YES=false
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

setup_log() {
    local level="$1" color="$2"
    shift 2
    if [[ -t 2 && -z "${NO_COLOR:-}" ]]; then
        printf '\033[%sm[%s]\033[0m %s\n' "$color" "$level" "$*" >&2
    else
        printf '[%s] %s\n' "$level" "$*" >&2
    fi
}

print_status() {
    setup_log INFO 34 "$@"
}

print_success() {
    setup_log SUCCESS 32 "$@"
}

print_warning() {
    setup_log WARNING 33 "$@"
}

print_error() {
    setup_log ERROR 31 "$@"
}

setup_on_error() {
    local status="$1" command="$2" source_file="$3" line="$4"
    print_error "Command failed with exit $status at $source_file:$line: $command"
    print_warning "Setup stopped. Completed installations are retained; fix the issue and rerun ./setup.sh."
    exit "$status"
}

setup_cleanup() {
    local temp_dir
    ((${#SETUP_TEMP_DIRS[@]})) || return 0
    for temp_dir in "${SETUP_TEMP_DIRS[@]}"; do
        if [[ -n "$temp_dir" && -d "$temp_dir" ]]; then rm -rf -- "$temp_dir"; fi
    done
}

setup_make_temp_dir() {
    SETUP_LAST_TEMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-setup.XXXXXX")" || return 1
    SETUP_TEMP_DIRS+=("$SETUP_LAST_TEMP_DIR")
    export SETUP_LAST_TEMP_DIR
}

record_optional_failure() {
    OPTIONAL_FAILURES+=("$1")
    print_warning "$1 failed; continuing with the remaining setup."
}

report_optional_failures() {
    if ((${#OPTIONAL_FAILURES[@]})); then
        SETUP_PARTIAL=true
        print_warning "Setup completed with ${#OPTIONAL_FAILURES[@]} optional issue(s):"
        printf '  - %s\n' "${OPTIONAL_FAILURES[@]}" >&2
        print_status "Resolve these items and rerun ./setup.sh; installed components will be detected."
    else
        print_success "Dotfiles setup completed without optional failures."
    fi
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

