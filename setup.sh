#!/bin/bash

# Dotfiles Setup Script
# This script sets up a fresh Ubuntu environment with dotfiles configurations

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Get the directory where this script is located (the dotfiles repo)
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
print_status "Dotfiles directory: $DOTFILES_DIR"

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
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

# Update system packages
print_status "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install essential packages
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

# Install development tools
print_status "Installing development tools..."
sudo apt install -y \
    tmux \
    zsh \
    ripgrep \
    fd-find \
    tree \
    htop \
    unzip \
    python3 \
    python3-pip \
    nodejs \
    npm \
    xclip \
    docker.io \
    docker-compose \
    golang-go \
    php \
    composer \
    snapd

# Install Neovim (latest stable version)
print_status "Installing Neovim..."
if ! command_exists nvim; then
    # Add Neovim PPA for latest version
    sudo add-apt-repository ppa:neovim-ppa/stable -y
    sudo apt update
    sudo apt install -y neovim
else
    print_success "Neovim already installed"
fi

# Install Ranger file manager
print_status "Installing Ranger..."
sudo apt install -y ranger

# Install Kitty terminal (if not in a headless environment)
if [[ -n "$DISPLAY" ]] || [[ -n "$WAYLAND_DISPLAY" ]]; then
    print_status "Installing Kitty terminal..."
    if ! command_exists kitty; then
        curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
        # Create desktop integration
        ln -sf ~/.local/kitty.app/bin/kitty ~/.local/bin/
        cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications/
        sed -i "s|Icon=kitty|Icon=/home/$USER/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" ~/.local/share/applications/kitty*.desktop
        
        # Create .local/share/applications directory if it doesn't exist
        mkdir -p ~/.local/share/applications
        # Update desktop database
        if command_exists update-desktop-database; then
            update-desktop-database ~/.local/share/applications
        fi
    else
        print_success "Kitty already installed"
    fi
    
    # Install fonts from dotfiles repo if they exist
    print_status "Installing fonts from dotfiles repository..."
    if [[ -d "$DOTFILES_DIR/fonts" ]]; then
        # Create fonts directory
        mkdir -p ~/.local/share/fonts
        
        # Copy all fonts from dotfiles/fonts to system fonts directory
        cp -r "$DOTFILES_DIR/fonts"/* ~/.local/share/fonts/ 2>/dev/null || true
        
        # Update font cache
        fc-cache -fv
        print_success "Custom fonts installed from dotfiles repository"
        
        # List installed fonts for confirmation
        font_count=$(find "$DOTFILES_DIR/fonts" -name "*.ttf" -o -name "*.otf" | wc -l)
        print_status "Installed $font_count font files from dotfiles"
    else
        print_warning "No fonts directory found in dotfiles. Installing Nerd Fonts automatically..."
        
        # Create fonts directory
        mkdir -p ~/.local/share/fonts
        
        # Install FiraCode Nerd Font
        print_status "Downloading and installing FiraCode Nerd Font..."
        cd /tmp
        wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/FiraCode.zip
        unzip -q FiraCode.zip -d FiraCode-NerdFont
        cp FiraCode-NerdFont/*.ttf ~/.local/share/fonts/
        rm -rf FiraCode.zip FiraCode-NerdFont
        
        # Install JetBrainsMono Nerd Font as backup
        print_status "Downloading and installing JetBrainsMono Nerd Font..."
        wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip
        unzip -q JetBrainsMono.zip -d JetBrainsMono-NerdFont
        cp JetBrainsMono-NerdFont/*.ttf ~/.local/share/fonts/
        rm -rf JetBrainsMono.zip JetBrainsMono-NerdFont
        
        cd - > /dev/null
        
        # Update font cache
        fc-cache -fv
        print_success "Nerd Fonts installed automatically"
        print_warning "Note: Operator Mono is a commercial font and needs to be installed manually"
    fi
else
    print_warning "No display detected, skipping Kitty installation"
fi

# Install Oh My Zsh
print_status "Installing Oh My Zsh..."
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    print_success "Oh My Zsh already installed"
fi

# Install zsh-autosuggestions to Oh My Zsh
print_status "Installing zsh-autosuggestions for Oh My Zsh..."
if [[ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    print_success "zsh-autosuggestions installed"
else
    print_success "zsh-autosuggestions already installed"
fi

# Install zsh-syntax-highlighting to Oh My Zsh
print_status "Installing zsh-syntax-highlighting for Oh My Zsh..."
if [[ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    print_success "zsh-syntax-highlighting installed"
else
    pri

# Install Powerlevel10k theme
print_status "Installing Powerlevel10k theme..."
if [[ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
else
    print_success "Powerlevel10k already installed"
fi

# Install useful Oh My Zsh plugins
print_status "Installing Oh My Zsh plugins..."

# zsh-autosuggestions
if [[ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi

# zsh-syntax-highlighting
if [[ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
fi

# Install additional tools referenced in .zshrc
print_status "Installing additional tools..."

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

# Install lazydocker
if ! command_exists lazydocker; then
    print_status "Installing lazydocker..."
    curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
else
    print_success "lazydocker already installed"
fi

# Enable and start Docker service
print_status "Setting up Docker..."
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER

# Install TPM (Tmux Plugin Manager)
print_status "Installing TPM (Tmux Plugin Manager)..."
if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    print_success "TPM installed. Plugins will be installed when you first run tmux."
else
    print_success "TPM already installed"
fi

# Create symbolic links for configuration files
print_status "Creating symbolic links for dotfiles..."

# Home directory files
if [[ -f "$DOTFILES_DIR/.tmux.conf" ]]; then
    create_symlink "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"
fi

if [[ -f "$DOTFILES_DIR/.zshrc" ]]; then
    create_symlink "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
fi

# .config directory configurations
if [[ -d "$DOTFILES_DIR/kitty" ]]; then
    create_symlink "$DOTFILES_DIR/kitty" "$HOME/.config/kitty"
fi

if [[ -d "$DOTFILES_DIR/nvim" ]]; then
    create_symlink "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
fi

if [[ -d "$DOTFILES_DIR/ranger" ]]; then
    create_symlink "$DOTFILES_DIR/ranger" "$HOME/.config/ranger"
fi

# Set Zsh as default shell
print_status "Setting Zsh as default shell..."
if [[ "$SHELL" != "$(which zsh)" ]]; then
    print_status "Changing default shell to Zsh (you may need to enter your password)"
    chsh -s $(which zsh)
    print_success "Default shell changed to Zsh. Please log out and back in for changes to take effect."
else
    print_success "Zsh is already the default shell"
fi

# Final message
print_success "Dotfiles setup completed!"
echo
print_status "Next steps:"
echo "  1. Log out and back in (or restart your terminal) to use Zsh"
echo "  2. Run 'p10k configure' to set up your Powerlevel10k theme"
echo "  3. Run 'tmux' to start a tmux session, then press 'Prefix + I' (Ctrl+Space + I) to install tmux plugins"
echo "  4. Run 'nvim' to start Neovim"
echo "  5. Run 'ranger' to start the file manager"
if [[ -n "$DISPLAY" ]] || [[ -n "$WAYLAND_DISPLAY" ]]; then
    echo "  6. Run 'kitty' to start the Kitty terminal"
fi
echo "  7. Docker commands: Use 'lzd' alias for lazydocker"
echo
print_warning "Important Security Note:"
echo "  Please create a .anthropic_key file to enable codecompanion integration"
print_warning "Additional notes:"
echo "  - Docker: You may need to log out/in for Docker group permissions"
echo "  - NVM: Latest LTS Node.js has been installed"
echo "  - Tmux: TPM installed. Use 'Prefix + I' to install plugins, 'Prefix + U' to update them"
echo "  - Your tmux prefix is set to Ctrl+Space (not the default Ctrl+b)"
echo "  - Kitty: All fonts installed from dotfiles repository (including Operator Mono)"
echo "  - Font count will be displayed during installation for verification"
echo "  - Automatic Nerd Font download available as fallback if fonts missing"
echo "  - Some configurations may require a full system restart to take effect."
