detect_environment() {
    local env_type=""
    
    # Check for WSL
    if [[ -n "${WSL_DISTRO_NAME:-}" ]] || [[ -n "${WSL_INTEROP:-}" ]] || grep -qi microsoft /proc/version 2>/dev/null; then
        env_type="wsl"
    # Check for display server (desktop environment)
    elif [[ -n "${DISPLAY:-}" ]] || [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
        env_type="desktop"
    # Check if we're in a container
    elif [[ -f /.dockerenv ]] || grep -q 'container=docker' /proc/1/environ 2>/dev/null; then
        env_type="container"
    # Check for SSH connection (likely headless server)
    elif [[ -n "${SSH_CLIENT:-}" ]] || [[ -n "${SSH_TTY:-}" ]]; then
        env_type="headless"
    # Check for common desktop packages
    elif command_exists gnome-shell || command_exists kde-plasma-desktop || command_exists xfce4-session; then
        env_type="desktop"
    # Default to headless if uncertain
    else
        env_type="headless"
    fi
    
    echo "$env_type"
}

ask_environment_type() {
    local detected_env="$1"
    local user_choice=""

    case "$SETUP_ENVIRONMENT" in
        desktop|headless|wsl|container) env_type="$SETUP_ENVIRONMENT"; return ;;
        ""|auto) ;;
        *) print_error "Unsupported environment: $SETUP_ENVIRONMENT"; exit 2 ;;
    esac

    if [[ "$SETUP_ASSUME_YES" == true || ! -t 0 || ! -r /dev/tty ]]; then
        env_type="$detected_env"
        print_status "Using detected environment: $env_type"
        return
    fi
    
    # Explicitly redirect to /dev/tty to ensure output goes to terminal
    {
        echo
        print_status "Environment Detection Results:"
        case "$detected_env" in
            "wsl")
                echo "  Detected: WSL (Windows Subsystem for Linux)"
                echo "  This will install terminal-only tools and skip GUI applications"
                ;;
            "desktop")
                echo "  Detected: Desktop Linux Environment"
                echo "  This will install GUI applications like Kitty terminal and fonts"
                ;;
            "container")
                echo "  Detected: Container Environment"
                echo "  This will install minimal tools suitable for containers"
                ;;
            "headless")
                echo "  Detected: Headless/Server Environment"
                echo "  This will install terminal-only tools and skip GUI applications"
                ;;
        esac
        
        echo
        echo "Choose installation type:"
        echo "  1) Desktop (GUI applications, fonts, terminal emulators)"
        echo "  2) Headless (terminal-only tools, no GUI applications)"
        echo "  3) WSL (optimized for Windows Subsystem for Linux)"
        echo "  4) Auto (use detected environment: $detected_env)"
        echo
    } >&2
    
    while true; do
        printf 'Enter your choice (1-4): ' > /dev/tty
        read -r user_choice < /dev/tty || { print_error "Could not read environment selection."; exit 2; }
        case "$user_choice" in
            1) env_type="desktop"; break ;;
            2) env_type="headless"; break ;;
            3) env_type="wsl"; break ;;
            4) env_type="$detected_env"; break ;;
            *) print_error "Please enter a valid choice (1-4)" ;;
        esac
    done
}

