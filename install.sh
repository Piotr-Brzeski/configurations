#!/usr/bin/env sh

SRC_DIR="$(cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P)"

# Parse arguments
FORCE_INSTALL=0
while [ $# -gt 0 ]; do
    case "$1" in
        -f|--force)
            FORCE_INSTALL=1
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  -f, --force    Override existing files and symlinks"
            echo "  -h, --help     Show this help message"
            echo ""
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Run '$0 --help' for usage information."
            exit 1
            ;;
    esac
done

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

# Check if a symlink can be created safely
check_symlink() {
    local src="$1"
    local dst="$2"

    if [ -e "$dst" ] || [ -L "$dst" ]; then
        # Target exists - check if it's already our symlink
        if [ -L "$dst" ]; then
            local current_target="$(readlink "$dst")"
            if [ "$current_target" = "$src" ]; then
                echo "${YELLOW}⚠${NC}  $dst already points to $src (will skip)"
                return 0
            else
                if [ $FORCE_INSTALL -eq 1 ]; then
                    echo "${YELLOW}⚠${NC}  $dst exists and points to $current_target (will override)"
                    return 0
                else
                    echo "${RED}✗${NC} $dst exists and points to $current_target (not $src)"
                    return 1
                fi
            fi
        else
            if [ $FORCE_INSTALL -eq 1 ]; then
                echo "${YELLOW}⚠${NC}  $dst exists and is not a symlink (will override)"
                return 0
            else
                echo "${RED}✗${NC} $dst exists and is not a symlink"
                return 1
            fi
        fi
    else
        echo "${GREEN}✓${NC} $dst can be created"
        return 0
    fi
}

# Pre-flight checks for all symlinks
echo "Checking if symlinks can be created..."
SYMLINK_ERRORS=0

# Check root-only tools
if [ "$(id -u)" -eq 0 ]; then
    check_symlink "$SRC_DIR/t" "/usr/local/bin/t" || SYMLINK_ERRORS=$((SYMLINK_ERRORS + 1))
    check_symlink "$SRC_DIR/tssh" "/usr/local/bin/tssh" || SYMLINK_ERRORS=$((SYMLINK_ERRORS + 1))
    check_symlink "$SRC_DIR/tmux-db.sh" "/usr/local/bin/tmux-db.sh" || SYMLINK_ERRORS=$((SYMLINK_ERRORS + 1))
fi

# Check home directory configs
check_symlink "$SRC_DIR/zshrc" "$HOME/.zshrc" || SYMLINK_ERRORS=$((SYMLINK_ERRORS + 1))
check_symlink "$SRC_DIR/gitconfig" "$HOME/.gitconfig" || SYMLINK_ERRORS=$((SYMLINK_ERRORS + 1))
check_symlink "$SRC_DIR/gitignore" "$HOME/.gitignore" || SYMLINK_ERRORS=$((SYMLINK_ERRORS + 1))
check_symlink "$SRC_DIR/tmux.conf" "$HOME/.tmux.conf" || SYMLINK_ERRORS=$((SYMLINK_ERRORS + 1))
check_symlink "$SRC_DIR/zed-keymap.json" "$HOME/.config/zed/keymap.json" || SYMLINK_ERRORS=$((SYMLINK_ERRORS + 1))
check_symlink "$SRC_DIR/zed-settings.json" "$HOME/.config/zed/settings.json" || SYMLINK_ERRORS=$((SYMLINK_ERRORS + 1))
check_symlink "$SRC_DIR/nvim-init.lua" "$HOME/.config/nvim/init.lua" || SYMLINK_ERRORS=$((SYMLINK_ERRORS + 1))

# Check if lazy.nvim already exists
if [ -e "$HOME/.local/share/nvim/site/pack/lazy/start/lazy.nvim" ]; then
    echo "${YELLOW}⚠${NC}  $HOME/.local/share/nvim/site/pack/lazy/start/lazy.nvim already exists (will skip clone)"
fi

# Exit if any symlink would fail
if [ $SYMLINK_ERRORS -gt 0 ]; then
    echo ""
    echo "${RED}ERROR: $SYMLINK_ERRORS symlink(s) would fail.${NC}"
    echo ""
    echo "Please backup or remove conflicting files, then run this script again."
    echo "Or use --force to override existing files:"
    echo "  $0 --force"
    echo ""
    exit 1
fi

echo ""
echo "${GREEN}All symlinks can be created safely!${NC}"
echo ""

# Helper to create symlink (skip if already correct)
create_symlink() {
    local src="$1"
    local dst="$2"

    if [ -L "$dst" ]; then
        local current_target="$(readlink "$dst")"
        if [ "$current_target" = "$src" ]; then
            echo "  Skipping $dst (already correct)"
            return 0
        fi
    fi

    # Remove existing file/symlink if force mode is enabled
    if [ $FORCE_INSTALL -eq 1 ] && { [ -e "$dst" ] || [ -L "$dst" ]; }; then
        echo "  Removing existing $dst"
        rm -rf "$dst" || exit 1
    fi

    ln -s "$src" "$dst" || exit 1
    echo "  Created $dst"
}

# Create symlinks
echo "Creating symlinks..."

if [ "$(id -u)" -ne 0 ]; then
        echo "Skipping tools install - not run as root."
else
        create_symlink "$SRC_DIR/t" "/usr/local/bin/t"
        create_symlink "$SRC_DIR/tssh" "/usr/local/bin/tssh"
        create_symlink "$SRC_DIR/tmux-db.sh" "/usr/local/bin/tmux-db.sh"
fi

#create_symlink "$SRC_DIR/zprofile" "$HOME/.zprofile"
create_symlink "$SRC_DIR/zshrc" "$HOME/.zshrc"
create_symlink "$SRC_DIR/gitconfig" "$HOME/.gitconfig"
create_symlink "$SRC_DIR/gitignore" "$HOME/.gitignore"
create_symlink "$SRC_DIR/tmux.conf" "$HOME/.tmux.conf"

mkdir -p "$HOME/.config/zed"
create_symlink "$SRC_DIR/zed-keymap.json" "$HOME/.config/zed/keymap.json"
create_symlink "$SRC_DIR/zed-settings.json" "$HOME/.config/zed/settings.json"

mkdir -p "$HOME/.config/nvim"
mkdir -p "$HOME/.local/share/nvim/site/pack/lazy/start"

# Clone lazy.nvim if it doesn't exist
if [ ! -e "$HOME/.local/share/nvim/site/pack/lazy/start/lazy.nvim" ]; then
    echo "  Cloning lazy.nvim..."
    git clone --filter=blob:none https://github.com/folke/lazy.nvim.git --branch=stable "$HOME/.local/share/nvim/site/pack/lazy/start/lazy.nvim" || exit 1
else
    echo "  Skipping lazy.nvim clone (already exists)"
fi

create_symlink "$SRC_DIR/nvim-init.lua" "$HOME/.config/nvim/init.lua"

echo ""
echo "${GREEN}Installation completed successfully!${NC}"

exit 0
