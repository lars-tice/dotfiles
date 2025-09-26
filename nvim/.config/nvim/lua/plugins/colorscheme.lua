-- Tokyo Night colorscheme configuration
return {
  -- Add Tokyo Night
  {
    "folke/tokyonight.nvim",
    lazy = false, -- Load during startup as main colorscheme
    priority = 1000, -- Load before other plugins
    opts = {
      style = "night", -- Options: storm, moon, night, day
      transparent = false,
      terminal_colors = true,
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
        functions = {},
        variables = {},
        sidebars = "dark",
        floats = "dark",
      },
      sidebars = { "qf", "help", "vista_kind", "terminal", "packer" },
      day_brightness = 0.3,
      hide_inactive_statusline = false,
      dim_inactive = false,
      lualine_bold = false,
    },
  },

  -- Configure LazyVim to use Tokyo Night
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight",
    },
  },
}