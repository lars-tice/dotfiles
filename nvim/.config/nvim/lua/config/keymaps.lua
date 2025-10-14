-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Toggle Snacks Explorer
vim.keymap.set("n", "<leader>E", function()
  -- Check if Snacks Explorer window is open
  local explorer_open = false
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
    if ft == "snacks_explorer" then
      explorer_open = true
      vim.api.nvim_win_close(win, true)
      break
    end
  end
  
  -- If not open, open it
  if not explorer_open then
    Snacks.picker.explorer()
  end
end, { desc = "Toggle Snacks Explorer" })
