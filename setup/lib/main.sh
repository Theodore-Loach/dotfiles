usage() {
    cat <<'EOF'
Usage: ./setup.sh [OPTIONS]

Options:
  --env ENV   Choose desktop, headless, wsl, container, or auto
  -y, --yes   Use detected environment and keep an existing Neovim installation
  -h, --help  Show this help
EOF
}

parse_arguments() {
    while (($#)); do
        case "$1" in
            --env)
                (($# >= 2)) || { print_error "--env requires a value"; exit 2; }
                SETUP_ENVIRONMENT="$2"
                shift 2
                ;;
            --env=*) SETUP_ENVIRONMENT="${1#*=}"; shift ;;
            -y|--yes) SETUP_ASSUME_YES=true; shift ;;
            -h|--help) usage; exit 0 ;;
            *) print_error "Unknown option: $1"; print_status "Run ./setup.sh --help for usage."; exit 2 ;;
        esac
    done
}

main() {
    parse_arguments "$@"
    printf '\nDotfiles Setup\n==============\n\n'
    
    # Detect environment
    detected_env=$(detect_environment)
    
    # Ask user for confirmation or override (sets global env_type variable)
    ask_environment_type "$detected_env"
    
    print_status "Installing for environment type: $env_type"
    echo

    # Install packages based on environment
    install_system_packages "$env_type"
    ensure_ssh_key
    install_language_runtimes
    install_neovim_from_source
    
    # Install environment-specific tools
    install_environment_tools "$env_type"
    
    # Install common development tools
    install_development_tools
    
    # Install Zsh setup
    install_zsh_setup
    
    # Install Tmux setup
    install_tmux_setup
    
    # Create dotfiles symlinks
    create_dotfiles_symlinks "$env_type"
    
    # Set default shell
    set_default_shell
    
    # Display final messages
    display_final_messages "$env_type"
    report_optional_failures
}

