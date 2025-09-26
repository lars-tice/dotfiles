-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Font settings for GUI versions of Neovim (like Neovide)
if vim.g.neovide or vim.g.gui_running then
  vim.o.guifont = "JetBrainsMonoNerdFontMono-Regular:h14"
end

-- General UI improvements
vim.opt.pumblend = 10 -- Popup menu transparency
vim.opt.winblend = 10 -- Window transparency
vim.opt.termguicolors = true -- True color support
