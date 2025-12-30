#!/usr/bin/env sh

SRC_DIR="$(cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P)"

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
