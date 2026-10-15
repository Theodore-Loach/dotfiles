install_neovim_from_source() {
    print_status "Installing Neovim from source (latest master)..."
    
    # Install build dependencies
    print_status "Installing Neovim build dependencies..."
    sudo apt install -y \
        ninja-build \
        gettext \
        libtool \
        libtool-bin \
        autoconf \
        automake \
        pkg-config \
        unzip \
        curl \
        doxygen \
        libluajit-5.1-dev
    
    # Check if nvim is already installed and get version info
    if command_exists nvim; then
        local current_version rebuild_choice
        current_version=$(nvim --version | head -n1 | cut -d' ' -f2)
        print_status "Current Neovim version: $current_version"
        if [[ "$SETUP_ASSUME_YES" == true || ! -r /dev/tty ]]; then
            print_success "Keeping existing Neovim installation"
            return
        fi
        printf 'Rebuild Neovim from latest source? (y/N): ' > /dev/tty
        read -r rebuild_choice < /dev/tty || rebuild_choice=n
        if [[ ! "$rebuild_choice" =~ ^[Yy] ]]; then
            print_success "Keeping existing Neovim installation"
            return
        fi
    fi

    local build_dir commit_hash commit_date
    setup_make_temp_dir
    build_dir="$SETUP_LAST_TEMP_DIR"
    print_status "Building Neovim in a temporary directory."
    cd "$build_dir"
    
    # Clone Neovim repository
    print_status "Cloning Neovim repository (master branch)..."
    git clone --depth 1 https://github.com/neovim/neovim.git
    cd neovim
    
    # Get commit info for reference
    commit_hash=$(git rev-parse --short HEAD)
    commit_date=$(git log -1 --format=%cd --date=short)
    print_status "Building Neovim commit: $commit_hash ($commit_date)"
    
    # Build Neovim
    print_status "Building Neovim (this may take several minutes)..."
    make CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_INSTALL_PREFIX=/usr/local
    
    # Install Neovim
    print_status "Installing Neovim system-wide..."
    sudo make install
    
    cd "$DOTFILES_DIR"
    
    # Verify installation
    if command_exists nvim; then
        new_version=$(nvim --version | head -n1)
        print_success "Neovim installed successfully!"
        print_success "Version: $new_version"
        print_status "Commit: $commit_hash ($commit_date)"
    else
        print_error "Neovim installation failed!"
        return 1
    fi
    
    # Update alternatives (in case system had vim installed)
    print_status "Setting up alternatives for vi/vim..."
    sudo update-alternatives --install /usr/bin/vi vi /usr/local/bin/nvim 60
    sudo update-alternatives --install /usr/bin/vim vim /usr/local/bin/nvim 60
    sudo update-alternatives --install /usr/bin/editor editor /usr/local/bin/nvim 60
}

install_system_packages() {
    local env_type="$1"
    
    # Update system packages
    print_status "Updating system packages..."
    sudo apt update && sudo apt upgrade -y
    
    # Install essential packages (common to all environments)
    print_status "Installing essential packages..."
    sudo apt install -y \
        curl \
        wget \
        git \
        build-essential \
        software-properties-common \
        apt-transport-https \
        ca-certificates \
        gnupg \
        lsb-release \
        openssh-client
    
    # Install core development tools (common to all environments)
    print_status "Installing core development tools..."
    sudo apt install -y \
        tmux \
        zsh \
        ripgrep \
        tree \
        htop \
        unzip \
        python3 \
        python3-pip \
        python3-dev \
        nodejs \
        npm \
        xclip \
        docker.io \
        docker-compose \
        golang-go \
        php \
        php-cli \
        php-mbstring \
        php-xml \
        composer \
        jq \
        stow \
        ruby \
        ruby-dev \
        gcc \
        g++ \
        make \
        cmake \
        clang \
        llvm
    
    # Install fd-find (handle different package names)
    if apt-cache show fd-find > /dev/null 2>&1; then
        if ! sudo apt install -y fd-find; then record_optional_failure "fd-find"; fi
    elif apt-cache show fdfind > /dev/null 2>&1; then
        if ! sudo apt install -y fdfind; then record_optional_failure "fd-find"; fi
    fi
    
    # Environment-specific packages
    case "$env_type" in
        "desktop")
            print_status "Installing desktop-specific packages..."
            sudo apt install -y \
                ranger \
                snapd \
                fontconfig
            ;;
        "wsl")
            print_status "Installing WSL-specific packages..."
            sudo apt install -y \
                ranger \
                wslu  # WSL utilities
            ;;
        "headless"|"container")
            print_status "Installing headless/container-specific packages..."
            sudo apt install -y \
                ranger \
                screen
            ;;
    esac
    
}

install_language_runtimes() {
    print_status "Installing language-specific tools..."

    if command_exists gem; then
        print_status "Installing Ruby bundler..."
        if ! gem install bundler --user-install; then record_optional_failure "Ruby Bundler"; fi
    fi

    if ! command_exists zig; then
        print_status "Installing Zig language..."
        local zig_dir
        if setup_make_temp_dir; then
            zig_dir="$SETUP_LAST_TEMP_DIR"
            if curl -fsSL --retry 3 https://ziglang.org/download/0.11.0/zig-linux-x86_64-0.11.0.tar.xz \
                -o "$zig_dir/zig.tar.xz" && sudo tar -xf "$zig_dir/zig.tar.xz" -C /usr/local --strip-components=1; then
                print_success "Zig language installed"
            else
                record_optional_failure "Zig"
            fi
        else
            record_optional_failure "Zig temporary directory"
        fi
    else
        print_success "Zig already installed"
    fi

    if ! command_exists rustc; then
        print_status "Installing Rust..."
        if ! setup_make_temp_dir; then
            record_optional_failure "Rust installer workspace"
        else
            local installer_dir="$SETUP_LAST_TEMP_DIR"
            if curl --proto '=https' --tlsv1.2 -sSf --retry 3 https://sh.rustup.rs \
                -o "$installer_dir/rustup.sh" && sh "$installer_dir/rustup.sh" -y; then
                [[ ! -s "$HOME/.cargo/env" ]] || source "$HOME/.cargo/env"
            else
                record_optional_failure "Rust"
            fi
        fi
    else
        print_success "Rust already installed"
    fi
}

