#!/bin/bash

# Enhanced Dotfiles Setup Script
# This script sets up a fresh Ubuntu environment with dotfiles configurations
# Supports both desktop and headless/WSL environments

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Global variable for environment type
env_type=""

# Function to print colored output - fixed to use /dev/tty
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1" > /dev/tty
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" > /dev/tty
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" > /dev/tty
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1" > /dev/tty
}

# Get the directory where this script is located (the dotfiles repo)
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
print_status "Dotfiles directory: $DOTFILES_DIR"

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to detect environment type
detect_environment() {
    local env_type=""
    
    # Check for WSL
    if [[ -n "${WSL_DISTRO_NAME:-}" ]] || [[ -n "${WSL_INTEROP:-}" ]] || grep -qi microsoft /proc/version 2>/dev/null; then
        env_type="wsl"
    # Check for display server (desktop environment)
    elif [[ -n "$DISPLAY" ]] || [[ -n "$WAYLAND_DISPLAY" ]]; then
        env_type="desktop"
    # Check if we're in a container
    elif [[ -f /.dockerenv ]] || grep -q 'container=docker' /proc/1/environ 2>/dev/null; then
        env_type="container"
    # Check for SSH connection (likely headless server)
    elif [[ -n "$SSH_CLIENT" ]] || [[ -n "$SSH_TTY" ]]; then
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

# Function to ask user for environment confirmation - fixed with /dev/tty
ask_environment_type() {
    local detected_env="$1"
    local user_choice=""
    
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
    } > /dev/tty
    
    while true; do
        read -p "Enter your choice (1-4): " user_choice < /dev/tty
        case "$user_choice" in
            1) env_type="desktop"; break ;;
            2) env_type="headless"; break ;;
            3) env_type="wsl"; break ;;
            4) env_type="$detected_env"; break ;;
            *) print_error "Please enter a valid choice (1-4)" ;;
        esac
    done
}

# Function to create symbolic link with backup
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

# Function to install fonts (desktop environments only)
install_fonts() {
    print_status "Installing fonts..."
    
    # Create fonts directory
    mkdir -p ~/.local/share/fonts
    
    # Install fonts from dotfiles repo if they exist
    if [[ -d "$DOTFILES_DIR/fonts" ]]; then
        # Copy all fonts from dotfiles/fonts to system fonts directory
        cp -r "$DOTFILES_DIR/fonts"/* ~/.local/share/fonts/ 2>/dev/null || true
        
        # Update font cache
        fc-cache -fv > /dev/null 2>&1
        print_success "Custom fonts installed from dotfiles repository"
        
        # List installed fonts for confirmation
        font_count=$(find "$DOTFILES_DIR/fonts" -name "*.ttf" -o -name "*.otf" | wc -l)
        print_status "Installed $font_count font files from dotfiles"
    else
        print_warning "No fonts directory found in dotfiles. Installing Nerd Fonts automatically..."
        
        # Install FiraCode Nerd Font
        print_status "Downloading and installing FiraCode Nerd Font..."
        cd /tmp
        wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/FiraCode.zip
        unzip -q FiraCode.zip -d FiraCode-NerdFont
        cp FiraCode-NerdFont/*.ttf ~/.local/share/fonts/ 2>/dev/null || true
        rm -rf FiraCode.zip FiraCode-NerdFont
        
        # Install JetBrainsMono Nerd Font as backup
        print_status "Downloading and installing JetBrainsMono Nerd Font..."
        wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip
        unzip -q JetBrainsMono.zip -d JetBrainsMono-NerdFont
        cp JetBrainsMono-NerdFont/*.ttf ~/.local/share/fonts/ 2>/dev/null || true
        rm -rf JetBrainsMono.zip JetBrainsMono-NerdFont
        
        cd - > /dev/null
        
        # Update font cache
        fc-cache -fv > /dev/null 2>&1
        print_success "Nerd Fonts installed automatically"
        print_warning "Note: Operator Mono is a commercial font and needs to be installed manually"
    fi
}

# Function to install Kitty terminal (desktop environments only)
install_kitty() {
    print_status "Installing Kitty terminal..."
    if ! command_exists kitty; then
        curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
        
        # Create desktop integration
        mkdir -p ~/.local/bin
        mkdir -p ~/.local/share/applications
        
        ln -sf ~/.local/kitty.app/bin/kitty ~/.local/bin/
        cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications/
        sed -i "s|Icon=kitty|Icon=/home/$USER/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" ~/.local/share/applications/kitty*.desktop
        
        # Update desktop database
        if command_exists update-desktop-database; then
            update-desktop-database ~/.local/share/applications 2>/dev/null || true
        fi
        
        print_success "Kitty terminal installed"
    else
        print_success "Kitty already installed"
    fi
}

# Function to install Neovim from source
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
        current_version=$(nvim --version | head -n1 | cut -d' ' -f2)
        print_status "Current Neovim version: $current_version"
        
        # Ask if user wants to rebuild/update
        while true; do
            read -p "Neovim is already installed. Rebuild from latest source? (y/n): " rebuild_choice < /dev/tty
            case "$rebuild_choice" in
                [Yy]*) break ;;
                [Nn]*) print_success "Keeping existing Neovim installation"; return ;;
                *) print_error "Please answer yes or no" ;;
            esac
        done
    fi
    
    # Create temporary build directory
    BUILD_DIR="/tmp/neovim-build"
    print_status "Creating build directory: $BUILD_DIR"
    rm -rf "$BUILD_DIR"
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"
    
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
    
    # Cleanup
    print_status "Cleaning up build directory..."
    cd /
    rm -rf "$BUILD_DIR"
    
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

# Function to install packages based on environment
install_packages() {
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
        lsb-release
    
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
    
    # Install language-specific tools and runtimes
    print_status "Installing language-specific tools..."
    
    # Ruby gems
    if command_exists gem; then
        print_status "Installing Ruby bundler..."
        gem install bundler --user-install
    fi
    
    # Install Zig language
    if ! command_exists zig; then
        print_status "Installing Zig language..."
        ZIG_VERSION="0.11.0"
        wget -q "https://ziglang.org/download/${ZIG_VERSION}/zig-linux-x86_64-${ZIG_VERSION}.tar.xz" -O /tmp/zig.tar.xz
        sudo tar -xf /tmp/zig.tar.xz -C /usr/local --strip-components=1
        rm /tmp/zig.tar.xz
        print_success "Zig language installed"
    else
        print_success "Zig already installed"
    fi
    
    # Install Rust (for additional tooling)
    if ! command_exists rustc; then
        print_status "Installing Rust..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source ~/.cargo/env
    else
        print_success "Rust already installed"
    fi
    
    # Install fd-find (handle different package names)
    if apt-cache show fd-find > /dev/null 2>&1; then
        sudo apt install -y fd-find
    elif apt-cache show fdfind > /dev/null 2>&1; then
        sudo apt install -y fdfind
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
    
    # Install Neovim from source (moved to separate function)
    install_neovim_from_source
}

# Function to install environment-specific tools
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

# Function to install common development tools
install_development_tools() {
    # Install fzf (fuzzy finder)
    if ! command_exists fzf; then
        print_status "Installing fzf..."
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
        ~/.fzf/install --all
    else
        print_success "fzf already installed"
    fi
    
    # Install NVM (Node Version Manager)
    if [[ ! -d "$HOME/.nvm" ]]; then
        print_status "Installing NVM..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        # Install latest LTS Node
        nvm install --lts
        nvm use --lts
    else
        print_success "NVM already installed"
    fi
    
    # Install TypeScript globally for Node.js
    if command_exists npm; then
        print_status "Installing TypeScript and Node.js global packages..."
        npm install -g typescript ts-node @types/node
    fi
    
    # Install lazydocker
    if ! command_exists lazydocker; then
        print_status "Installing lazydocker..."
        curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
    else
        print_success "lazydocker already installed"
    fi
    
    # Install lazygit
    if ! command_exists lazygit; then
        print_status "Installing lazygit..."
        LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
        curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
        tar xf lazygit.tar.gz lazygit
        sudo install lazygit /usr/local/bin
        rm lazygit lazygit.tar.gz
    else
        print_success "lazygit already installed"
    fi
    
    # Install bpytop
    if ! command_exists bpytop; then
        print_status "Installing bpytop..."
        pip3 install bpytop --user
    else
        print_success "bpytop already installed"
    fi
    
    # Enable and start Docker service
    print_status "Setting up Docker..."
    sudo systemctl enable docker
    sudo systemctl start docker
    sudo usermod -aG docker $USER
}

# Function to install Zsh and Oh My Zsh
install_zsh_setup() {
    # Install Oh My Zsh
    print_status "Installing Oh My Zsh..."
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        print_success "Oh My Zsh already installed"
    fi
    
    # Install zsh-autosuggestions
    print_status "Installing zsh-autosuggestions..."
    if [[ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    else
        print_success "zsh-autosuggestions already installed"
    fi
    
    # Install zsh-syntax-highlighting
    print_status "Installing zsh-syntax-highlighting..."
    if [[ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    else
        print_success "zsh-syntax-highlighting already installed"
    fi
    
    # Install Powerlevel10k theme
    print_status "Installing Powerlevel10k theme..."
    if [[ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]]; then
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    else
        print_success "Powerlevel10k already installed"
    fi
}

# Function to install Tmux setup
install_tmux_setup() {
    # Install TPM (Tmux Plugin Manager)
    print_status "Installing TPM (Tmux Plugin Manager)..."
    if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
        git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
        print_success "TPM installed. Plugins will be installed when you first run tmux."
    else
        print_success "TPM already installed"
    fi
}

# Function to create dotfiles symlinks
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

# Function to set default shell
set_default_shell() {
    print_status "Setting Zsh as default shell..."
    if [[ "$SHELL" != "$(which zsh)" ]]; then
        print_status "Changing default shell to Zsh (you may need to enter your password)"
        chsh -s $(which zsh)
        print_success "Default shell changed to Zsh. Please log out and back in for changes to take effect."
    else
        print_success "Zsh is already the default shell"
    fi
}

# Function to display final messages
display_final_messages() {
    local env_type="$1"
    
    print_success "Dotfiles setup completed!"
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
    echo "  - ssh: your .zshrc expect a key 'id_ed25519' on start, please create or disable this code"
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

# Main execution
main() {
    {
        echo "=========================================="
        echo "           Dotfiles Setup Script"
        echo "=========================================="
        echo
    } > /dev/tty
    
    # Detect environment
    detected_env=$(detect_environment)
    
    # Ask user for confirmation or override (sets global env_type variable)
    ask_environment_type "$detected_env"
    
    print_status "Installing for environment type: $env_type"
    echo
    
    # Install packages based on environment
    install_packages "$env_type"
    
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
}

# Run main function
main "$@"

