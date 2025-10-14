-- Override LazyVim's automatic debugpy installation
-- We manage debugpy ourselves via uv
return {
  {
    "jay-babu/mason-nvim-dap.nvim",
    opts = {
      -- Don't auto-install debugpy - we handle it via uv
      ensure_installed = {},
      handlers = {
        -- Disable the automatic python debugpy setup
        python = function() end,
      },
    },
  },
}
