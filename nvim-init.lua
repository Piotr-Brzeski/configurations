-- ~/.config/nvim/init.lua

vim.opt.number = true
vim.o.laststatus = 0

-- Bootstrap lazy.nvim plugin manager
-- git clone --filter=blob:none https://github.com/folke/lazy.nvim.git --branch=stable ~/.local/share/nvim/site/pack/lazy/start/lazy.nvim
vim.opt.rtp:prepend("~/.local/share/nvim/site/pack/lazy/start/lazy.nvim")

require("lazy").setup({
  {
    "mg979/vim-visual-multi",
    branch = "master",
  },
})

