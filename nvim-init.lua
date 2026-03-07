-- ~/.config/nvim/init.lua

vim.opt.number = true
vim.o.laststatus = 0
vim.o.ruler = true

local function update_ruler()
  if vim.o.mouse == '' then
    vim.o.rulerformat = '%-24(%l,%c%V%)%=  %P  📋 '
  else
    vim.o.rulerformat = '%-24(%l,%c%V%)%=  %P  🐁 '
  end
end
update_ruler()
vim.keymap.set('n', '<leader>m', function()
  if vim.o.mouse == '' then
    vim.o.mouse = 'a'
  else
    vim.o.mouse = ''
  end
  update_ruler()
end, { desc = 'Toggle mouse' })

-- Bootstrap lazy.nvim plugin manager
-- git clone --filter=blob:none https://github.com/folke/lazy.nvim.git --branch=stable ~/.local/share/nvim/site/pack/lazy/start/lazy.nvim
vim.opt.rtp:prepend("~/.local/share/nvim/site/pack/lazy/start/lazy.nvim")

require("lazy").setup({
  {
    "mg979/vim-visual-multi",
    branch = "master",
  },
})

