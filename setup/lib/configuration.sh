create_symlink() {
    local source="$1"
    local target="$2"
    
    # Create target directory if it doesn't exist
    local target_dir=$(dirname "$target")
    if [[ ! -d "$target_dir" ]]; then
        print_status "Creating directory: $target_dir"
        mkdir -p "$target_dir"
    fi
    
    # Backup existing file/directory if it exists and isn't already a symlink to our source
    if [[ -e "$target" ]] && [[ ! -L "$target" || "$(readlink "$target")" != "$source" ]]; then
        local backup="${target}.backup.$(date +%Y%m%d_%H%M%S)"
        print_warning "Backing up existing $target to $backup"
        mv "$target" "$backup"
    fi
    
    # Remove broken symlinks
    if [[ -L "$target" ]] && [[ ! -e "$target" ]]; then
        print_warning "Removing broken symlink: $target"
        rm "$target"
    fi
    
    # Create symlink if it doesn't already exist
    if [[ ! -L "$target" ]]; then
        print_status "Creating symlink: $target -> $source"
        ln -sf "$source" "$target"
    else
        print_success "Symlink already exists: $target"
    fi
}

create_dotfiles_symlinks() {
    local env_type="$1"
    
    print_status "Creating symbolic links for dotfiles..."
    
    # Home directory files
    if [[ -f "$DOTFILES_DIR/.tmux.conf" ]]; then
        create_symlink "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"
    fi
    
    if [[ -f "$DOTFILES_DIR/.zshrc" ]]; then
        create_symlink "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
    fi
    
    # .config directory configurations
    if [[ -d "$DOTFILES_DIR/nvim" ]]; then
        create_symlink "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
    fi
    
    if [[ -d "$DOTFILES_DIR/ranger" ]]; then
        create_symlink "$DOTFILES_DIR/ranger" "$HOME/.config/ranger"
    fi
    
    # Desktop-specific symlinks
    if [[ "$env_type" == "desktop" ]] && [[ -d "$DOTFILES_DIR/kitty" ]]; then
        create_symlink "$DOTFILES_DIR/kitty" "$HOME/.config/kitty"
    fi
}

ensure_ssh_key() {
    local ssh_dir="$HOME/.ssh"
    local private_key="$ssh_dir/id_ed25519"
    local public_key="$private_key.pub"
    local comment="${USER:-$(id -un)}@$(hostname)"
    local public_tmp

    if ! command_exists ssh-keygen; then
        record_optional_failure "SSH key setup (ssh-keygen is not installed)"
        return
    fi
    if ! mkdir -p "$ssh_dir" || ! chmod 700 "$ssh_dir"; then
        record_optional_failure "SSH directory permissions"
        return
    fi

    if [[ -f "$private_key" && -f "$public_key" ]]; then
        if chmod 600 "$private_key" && chmod 644 "$public_key"; then
            print_success "SSH Ed25519 keypair already exists at $private_key"
        else
            record_optional_failure "SSH key permissions"
        fi
        return
    fi

    if [[ -e "$private_key" ]]; then
        if ! chmod 600 "$private_key"; then
            record_optional_failure "SSH private key permissions"
            return
        fi
        if [[ ! -t 0 ]]; then
            record_optional_failure "SSH public key recovery (run ssh-keygen -y -f $private_key manually)"
            return
        fi
        public_tmp="$(mktemp "$ssh_dir/.id_ed25519.pub.XXXXXX")" || {
            record_optional_failure "SSH public key recovery"
            return
        }
        if ssh-keygen -y -f "$private_key" > "$public_tmp" \
            && chmod 644 "$public_tmp" \
            && mv "$public_tmp" "$public_key"; then
            print_success "Recovered the public key for the existing SSH private key."
        else
            rm -f -- "$public_tmp"
            record_optional_failure "SSH public key recovery"
        fi
        return
    fi

    if [[ -e "$public_key" ]]; then
        record_optional_failure "SSH keypair is incomplete: $public_key exists but its private key is missing; no files were overwritten"
        return
    fi
    if [[ ! -t 0 ]]; then
        record_optional_failure "SSH key generation (rerun from a terminal to choose a passphrase)"
        return
    fi

    print_status "Creating an Ed25519 SSH key at $private_key; ssh-keygen will prompt for a passphrase."
    if ssh-keygen -q -t ed25519 -a 100 -C "$comment" -f "$private_key" \
        && chmod 600 "$private_key" \
        && chmod 644 "$public_key"; then
        print_success "Created SSH keypair at $private_key and $public_key"
    else
        record_optional_failure "SSH key generation"
    fi
}

set_default_shell() {
    print_status "Setting Zsh as default shell..."
    local zsh_path
    zsh_path="$(command -v zsh)" || { record_optional_failure "Default Zsh shell"; return; }
    if [[ "${SHELL:-}" != "$zsh_path" ]]; then
        print_status "Changing default shell to Zsh (you may need to enter your password)"
        if ! chsh -s "$zsh_path"; then
            record_optional_failure "Default Zsh shell"
            return
        fi
        print_success "Default shell changed to Zsh. Please log out and back in for changes to take effect."
    else
        print_success "Zsh is already the default shell"
    fi
}

display_final_messages() {
    local env_type="$1"
    
    print_status "Setup steps finished."
    echo
    print_status "Environment: $env_type"
    echo
    print_status "Next steps:"
    echo "  1. Log out and back in (or restart your terminal) to use Zsh"
    echo "  2. Run 'p10k configure' to set up your Powerlevel10k theme"
    echo "  3. Run 'tmux' to start a tmux session, then press 'Prefix + I' (Ctrl+Space + I) to install tmux plugins"
    echo "  4. Run 'nvim' to start Neovim"
    echo "  5. Run 'ranger' to start the file manager"
    
    case "$env_type" in
        "desktop")
            echo "  6. Run 'kitty' to start the Kitty terminal"
            echo "  7. Custom fonts have been installed and are available system-wide"
            ;;
        "wsl")
            echo "  6. Configure your Windows Terminal or preferred terminal emulator"
            echo "  7. Consider installing a Nerd Font in your Windows terminal settings"
            ;;
        "headless"|"container")
            echo "  6. All terminal-based tools are ready to use"
            ;;
    esac
    
    echo "  8. Docker commands: Use 'lzd' alias for lazydocker, 'lg' for lazygit"
    echo "  9. System monitoring: Use 'bpytop' for enhanced system monitoring"
    echo
    print_warning "Important Security Note:"
    echo "  Please create a .anthropic_key file to enable codecompanion integration"
    echo
    print_warning "Additional notes:"
    echo "  - SSH: an Ed25519 key is created in ~/.ssh when missing; private keys stay out of the dotfiles repository"
    echo "  - Docker: You may need to log out/in for Docker group permissions"
    echo "  - NVM: Latest LTS Node.js has been installed with TypeScript support"
    echo "  - Languages: Zig, PHP, JS/TS, Python 3, C/C++, Ruby, Go, Rust are installed"
    echo "  - Tmux: TPM installed. Use 'Prefix + I' to install plugins, 'Prefix + U' to update them"
    echo "  - Your tmux prefix is set to Ctrl+Space (not the default Ctrl+b)"
    echo "  - Neovim: Built from latest master source for cutting-edge features"
    
    if [[ "$env_type" == "desktop" ]]; then
        echo "  - Kitty: Terminal emulator installed with desktop integration"
        echo "  - Fonts: All custom fonts installed and font cache updated"
    fi
    
    echo "  - Some configurations may require a full system restart to take effect."
}

