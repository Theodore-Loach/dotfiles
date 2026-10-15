install_fonts() {
    print_status "Installing fonts..."

    mkdir -p "$HOME/.local/share/fonts"
    if [[ -d "$DOTFILES_DIR/fonts" ]]; then
        if ! cp -r "$DOTFILES_DIR/fonts"/. "$HOME/.local/share/fonts/"; then
            record_optional_failure "Custom fonts"
            return
        fi
        if command_exists fc-cache && fc-cache -f >/dev/null 2>&1; then
            local font_count
            font_count=$(find "$DOTFILES_DIR/fonts" -type f \( -name '*.ttf' -o -name '*.otf' \) | wc -l)
            print_success "Installed $font_count font files from the dotfiles repository."
        else
            record_optional_failure "Font cache refresh"
        fi
    else
        print_warning "No repository fonts found; skipping automatic font downloads."
    fi
}

install_kitty() {
    print_status "Installing Kitty terminal..."
    if command_exists kitty; then
        print_success "Kitty already installed"
        return
    fi

    if ! setup_make_temp_dir; then record_optional_failure "Kitty installer workspace"; return; fi
    local installer_dir="$SETUP_LAST_TEMP_DIR"
    if ! curl -fsSL --retry 3 https://sw.kovidgoyal.net/kitty/installer.sh -o "$installer_dir/installer.sh" \
        || ! sh "$installer_dir/installer.sh"; then
        record_optional_failure "Kitty terminal"
        return
    fi

    if ! mkdir -p "$HOME/.local/bin" "$HOME/.local/share/applications" \
        || ! ln -sf "$HOME/.local/kitty.app/bin/kitty" "$HOME/.local/bin/kitty"; then
        record_optional_failure "Kitty integration"
        return
    fi
    if [[ -f "$HOME/.local/kitty.app/share/applications/kitty.desktop" ]] \
        && ! cp "$HOME/.local/kitty.app/share/applications/kitty.desktop" "$HOME/.local/share/applications/"; then
        record_optional_failure "Kitty desktop entry"
        return
    fi
    print_success "Kitty terminal installed"
}

install_environment_tools() {
    local env_type="$1"
    
    case "$env_type" in
        "desktop")
            install_kitty
            install_fonts
            ;;
        "wsl")
            print_status "WSL environment detected - skipping GUI applications"
            print_warning "Use Windows Terminal or your preferred terminal emulator"
            ;;
        "headless"|"container")
            print_status "Headless environment detected - skipping GUI applications"
            ;;
    esac
}

install_fzf() {
    command_exists fzf && { print_success "fzf already installed"; return; }
    print_status "Installing fzf..."
    if [[ ! -d "$HOME/.fzf" ]] \
        && ! install_git_checkout "fzf" https://github.com/junegunn/fzf.git "$HOME/.fzf" --depth 1; then
        return
    fi
    if [[ -x "$HOME/.fzf/install" ]] && "$HOME/.fzf/install" --all; then
        print_success "fzf installed"
    else
        record_optional_failure "fzf"
    fi
}

install_nvm_and_node() {
    if [[ ! -d "$HOME/.nvm" ]]; then
        if ! setup_make_temp_dir; then record_optional_failure "NVM installer workspace"; return; fi
        local installer_dir="$SETUP_LAST_TEMP_DIR"
        if ! curl -fsSL --retry 3 https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh \
            -o "$installer_dir/install.sh" || ! bash "$installer_dir/install.sh"; then
            record_optional_failure "NVM"
            return
        fi
    fi

    export NVM_DIR="$HOME/.nvm"
    local restore_nounset=false
    if [[ "$-" == *u* ]]; then
        restore_nounset=true
        set +u
    fi
    if [[ -s "$NVM_DIR/nvm.sh" ]]; then source "$NVM_DIR/nvm.sh"; fi
    if ! command_exists nvm || ! nvm install --lts || ! nvm use --lts; then
        if [[ "$restore_nounset" == true ]]; then set -u; fi
        record_optional_failure "Node.js LTS"
        return
    fi
    if [[ "$restore_nounset" == true ]]; then set -u; fi
    if ! npm install -g typescript ts-node @types/node; then
        record_optional_failure "TypeScript global packages"
    fi
}

install_lazydocker() {
    if command_exists lazydocker || [[ -x "$HOME/.local/bin/lazydocker" ]]; then
        print_success "lazydocker already installed"
        return
    fi
    print_status "Installing lazydocker..."

    if ! setup_make_temp_dir; then record_optional_failure "lazydocker installer workspace"; return; fi
    local temp_dir="$SETUP_LAST_TEMP_DIR" install_dir="$HOME/.local/bin"
    if ! mkdir -p "$install_dir" \
        || ! curl -fsSL --retry 3 \
            https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh \
            -o "$temp_dir/install.sh"; then
        record_optional_failure "lazydocker download"
        return
    fi

    if (cd "$temp_dir" && DIR="$install_dir" bash -e "$temp_dir/install.sh"); then
        print_success "lazydocker installed to $install_dir"
    else
        record_optional_failure "lazydocker installation"
    fi
}

install_lazygit() {
    command_exists lazygit && { print_success "lazygit already installed"; return; }
    print_status "Installing lazygit..."

    local release_json version arch
    if ! release_json="$(curl -fsSL --retry 3 https://api.github.com/repos/jesseduffield/lazygit/releases/latest)"; then
        record_optional_failure "lazygit release lookup"
        return
    fi
    if ! version="$(printf '%s' "$release_json" | jq -er '.tag_name | ltrimstr("v")')"; then
        record_optional_failure "lazygit version parsing"
        return
    fi
    case "$(uname -m)" in
        x86_64) arch=x86_64 ;;
        aarch64) arch=arm64 ;;
        *) record_optional_failure "lazygit (unsupported architecture)"; return ;;
    esac

    if ! setup_make_temp_dir; then record_optional_failure "lazygit installer workspace"; return; fi
    local temp_dir="$SETUP_LAST_TEMP_DIR"
    if ! curl -fsSL --retry 3 \
        "https://github.com/jesseduffield/lazygit/releases/download/v${version}/lazygit_${version}_Linux_${arch}.tar.gz" \
        -o "$temp_dir/lazygit.tar.gz" \
        || ! tar -xzf "$temp_dir/lazygit.tar.gz" -C "$temp_dir" lazygit \
        || ! sudo install -m 0755 "$temp_dir/lazygit" /usr/local/bin/lazygit; then
        record_optional_failure "lazygit installation"
        return
    fi
    print_success "lazygit installed"
}

install_docker_service() {
    print_status "Setting up Docker..."
    if ! sudo systemctl enable --now docker; then
        record_optional_failure "Docker service (systemd may be unavailable)"
        return
    fi
    if ! sudo usermod -aG docker "${USER:-$(id -un)}"; then
        record_optional_failure "Docker group membership"
    fi
}

install_development_tools() {
    install_fzf
    install_nvm_and_node
    install_lazydocker
    install_lazygit

    if ! command_exists bpytop && ! sudo apt install -y bpytop; then
        record_optional_failure "bpytop"
    fi
    install_docker_service
}

install_zsh_setup() {
    print_status "Installing Oh My Zsh..."
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        if ! setup_make_temp_dir; then record_optional_failure "Oh My Zsh installer workspace"; return; fi
        local installer_dir="$SETUP_LAST_TEMP_DIR"
        if ! curl -fsSL --retry 3 https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh \
            -o "$installer_dir/install.sh" || ! bash "$installer_dir/install.sh" --unattended; then
            record_optional_failure "Oh My Zsh"
            return
        fi
    else
        print_success "Oh My Zsh already installed"
    fi

    local custom_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    install_git_checkout "zsh-autosuggestions" https://github.com/zsh-users/zsh-autosuggestions "$custom_dir/plugins/zsh-autosuggestions" || true
    install_git_checkout "zsh-syntax-highlighting" https://github.com/zsh-users/zsh-syntax-highlighting.git "$custom_dir/plugins/zsh-syntax-highlighting" || true
    install_git_checkout "Powerlevel10k" https://github.com/romkatv/powerlevel10k.git "$custom_dir/themes/powerlevel10k" --depth=1 || true
}

install_git_checkout() {
    local label="$1" url="$2" destination="$3" temp_dir
    shift 3
    [[ -d "$destination" ]] && return
    if ! mkdir -p "$(dirname "$destination")" || ! setup_make_temp_dir; then
        record_optional_failure "$label workspace"
        return 1
    fi
    temp_dir="$SETUP_LAST_TEMP_DIR/checkout"
    if ! git clone "$@" "$url" "$temp_dir" || ! mv "$temp_dir" "$destination"; then
        record_optional_failure "$label"
        return 1
    fi
    return 0
}

install_tmux_setup() {
    print_status "Installing TPM (Tmux Plugin Manager)..."
    if [[ -d "$HOME/.tmux/plugins/tpm" ]]; then
        print_success "TPM already installed"
    else
        install_git_checkout "Tmux Plugin Manager" https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm" || true
    fi
    if [[ -d "$HOME/.tmux/plugins/tpm" ]]; then
        print_success "TPM installed. Plugins will be installed when you first run tmux."
    fi
}

