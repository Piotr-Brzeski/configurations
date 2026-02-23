#!/usr/bin/env sh

SRC_DIR="$(cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P)"

# Check if current shell is zsh
if [ -z "$ZSH_VERSION" ]; then
    echo "ERROR: This script must be run in zsh, not $SHELL"
    echo ""
    echo "Please run:"
    echo "  zsh $0"
    echo ""
    echo "Or change your default shell to zsh:"
    echo "  chsh -s \$(which zsh)"
    echo ""
    exit 1
fi

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if a command exists
check_command() {
    if command -v "$1" >/dev/null 2>&1; then
        echo "${GREEN}✓${NC} $1 is installed"
        return 0
    else
        echo "${RED}✗${NC} $1 is NOT installed"
        return 1
    fi
}

# Dependency checks
echo "Checking required dependencies..."
MISSING_DEPS=0

# Critical tools required for basic functionality
check_command "git" || MISSING_DEPS=$((MISSING_DEPS + 1))
check_command "zsh" || MISSING_DEPS=$((MISSING_DEPS + 1))
check_command "tmux" || MISSING_DEPS=$((MISSING_DEPS + 1))
check_command "fzf" || MISSING_DEPS=$((MISSING_DEPS + 1))
check_command "sqlite3" || MISSING_DEPS=$((MISSING_DEPS + 1))
check_command "nvim" || MISSING_DEPS=$((MISSING_DEPS + 1))

# Optional tools (warnings only)
#echo ""
#echo "Checking optional dependencies..."
#if ! check_command "netns"; then
#    echo "${YELLOW}⚠${NC}  netns is optional (required for 'ns' script)"
#fi

# Exit if critical dependencies are missing
if [ $MISSING_DEPS -gt 0 ]; then
    echo ""
    echo "${RED}ERROR: $MISSING_DEPS required tool(s) missing.${NC}"
    echo ""
    echo "Installation commands for macOS (using Homebrew):"
    echo "  brew install git zsh tmux fzf sqlite neovim"
    echo ""
    echo "For other systems, use your package manager:"
    echo "  Ubuntu/Debian: sudo apt install git zsh tmux fzf sqlite3 neovim"
    echo "  Fedora/RHEL:   sudo dnf install git zsh tmux fzf sqlite neovim"
    echo "  Arch:          sudo pacman -S git zsh tmux fzf sqlite neovim"
    echo ""
    exit 1
fi

echo ""
echo "${GREEN}All required dependencies are installed!${NC}"
echo ""

if [ "$(id -u)" -ne 0 ]; then
        echo "Skipping tools install - not run as root."
else
        ln -s "$SRC_DIR/t" /usr/local/bin/t || exit 1
        ln -s "$SRC_DIR/tssh" /usr/local/bin/tssh || exit 1
        ln -s "$SRC_DIR/tmux-db.sh" /usr/local/bin/tmux-db.sh || exit 1
fi

#ln -s "$SRC_DIR/zprofile" ~/.zprofile || exit 1
ln -s "$SRC_DIR/zshrc" ~/.zshrc || exit 1
ln -s "$SRC_DIR/gitconfig" ~/.gitconfig || exit 1
ln -s "$SRC_DIR/gitignore" ~/.gitignore || exit 1
ln -s "$SRC_DIR/tmux.conf" ~/.tmux.conf || exit 1

mkdir -p ~/.config/zed
ln -s "$SRC_DIR/zed-keymap.json" ~/.config/zed/keymap.json || exit 1
ln -s "$SRC_DIR/zed-settings.json" ~/.config/zed/settings.json || exit 1

mkdir -p ~/.config/nvim
mkdir -p ~/.local/share/nvim/site/pack/lazy/start
git clone --filter=blob:none https://github.com/folke/lazy.nvim.git --branch=stable ~/.local/share/nvim/site/pack/lazy/start/lazy.nvim
ln -s "$SRC_DIR/nvim-init.lua" ~/.config/nvim/init.lua || exit 1

exit 0
