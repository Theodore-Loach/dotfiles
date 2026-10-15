#!/usr/bin/env bash
set -Eeuo pipefail
SETUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/setup/lib"
source "$SETUP_DIR/common.sh"
source "$SETUP_DIR/environment.sh"
source "$SETUP_DIR/packages.sh"
source "$SETUP_DIR/tools.sh"
source "$SETUP_DIR/configuration.sh"
source "$SETUP_DIR/main.sh"

trap 'setup_on_error "$?" "$BASH_COMMAND" "${BASH_SOURCE[1]:-${BASH_SOURCE[0]}}" "$LINENO"' ERR
trap setup_cleanup EXIT

main "$@"
if [[ "$SETUP_PARTIAL" == true ]]; then exit 1; fi
