return {
  -- Override LazyVim's Python extra to prevent warning
  -- Actual setup happens in nvim-dap config below
  {
    "mfussenegger/nvim-dap-python",
    config = function() end,
  },
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      {
        "mfussenegger/nvim-dap-python",
        keys = {
          -- Disable LazyVim's default Python debug keybindings
          { "<leader>dPt", false },
          { "<leader>dPc", false },
        },
      },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      -- Setup DAP UI
      dapui.setup({
        icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
        mappings = {
          expand = { "<CR>", "<2-LeftMouse>" },
          open = "o",
          remove = "d",
          edit = "e",
          repl = "r",
          toggle = "t",
        },
        layouts = {
          {
            elements = {
              { id = "scopes", size = 0.25 },
              "breakpoints",
              "stacks",
              "watches",
            },
            size = 50, -- Increased from 40 for better visibility
            position = "left",
          },
          {
            elements = {
              "repl",
              "console",
            },
            size = 15, -- Fixed height in lines instead of percentage
            position = "bottom",
          },
        },
        floating = {
          max_height = nil,
          max_width = nil,
          border = "single",
          mappings = {
            close = { "q", "<Esc>" },
          },
        },
        windows = { indent = 1 },
        render = {
          max_type_length = nil,
          max_value_lines = 100,
        },
      })

      -- Automatically open/close DAP UI
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      -- Define custom signs for breakpoints
      vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreakpoint", linehl = "", numhl = "" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DapBreakpointCondition", linehl = "", numhl = "" })
      vim.fn.sign_define("DapBreakpointRejected", { text = "✖", texthl = "DapBreakpointRejected", linehl = "", numhl = "" })
      vim.fn.sign_define("DapLogPoint", { text = "◆", texthl = "DapLogPoint", linehl = "", numhl = "" })
      vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DapStopped", linehl = "DapStopped", numhl = "DapStopped" })

      -- Set highlight colors for the signs
      vim.api.nvim_set_hl(0, "DapBreakpoint", { fg = "#e06c75" }) -- Red color
      vim.api.nvim_set_hl(0, "DapBreakpointCondition", { fg = "#e5c07b" }) -- Yellow color
      vim.api.nvim_set_hl(0, "DapBreakpointRejected", { fg = "#828997" }) -- Gray color
      vim.api.nvim_set_hl(0, "DapLogPoint", { fg = "#61afef" }) -- Blue color
      vim.api.nvim_set_hl(0, "DapStopped", { fg = "#98c379", bg = "#31353f" }) -- Green with background

      -- Setup Python debugging with uv support
      -- First ensure debugpy is installed (preferring uv)
      local installer = require("config.dap-uv-installer")
      installer.ensure_debugpy()

      -- Then setup dap-python with the correct Python path
      require("dap-python").setup(installer.get_python_path())

      -- Additional Python debug configurations
      table.insert(dap.configurations.python, {
        type = "python",
        request = "launch",
        name = "Debug entire file",
        program = "${file}",
        pythonPath = function()
          return installer.get_python_path()
        end,
        justMyCode = false, -- Allow breakpoints in all code, including libraries
        env = {
          DEBUGPY_RUNNING = "1",  -- Signal to conftest.py to disable coverage
        },
      })

      -- Pytest debug configuration
      table.insert(dap.configurations.python, {
        type = "python",
        request = "launch",
        name = "Debug pytest",
        module = "pytest",
        args = { "${file}", "-sv" },
        pythonPath = function()
          return installer.get_python_path()
        end,
        justMyCode = false,
        console = "integratedTerminal",
        env = {
          DEBUGPY_RUNNING = "1",  -- For future safety
        },
      })

    end,
    keys = {
      {
        "<leader>dB",
        function()
          require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
        end,
        desc = "Breakpoint Condition",
      },
      {
        "<leader>db",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "Toggle Breakpoint",
      },
      {
        "<leader>dc",
        function()
          require("dap").continue()
        end,
        desc = "Continue",
      },
      {
        "<leader>dC",
        function()
          require("dap").run_to_cursor()
        end,
        desc = "Run to Cursor",
      },
      {
        "<leader>dg",
        function()
          require("dap").goto_()
        end,
        desc = "Go to line (no execute)",
      },
      {
        "<leader>di",
        function()
          require("dap").step_into()
        end,
        desc = "Step Into",
      },
      {
        "<leader>dj",
        function()
          require("dap").down()
        end,
        desc = "Down",
      },
      {
        "<leader>dk",
        function()
          require("dap").up()
        end,
        desc = "Up",
      },
      {
        "<leader>dl",
        function()
          require("dap").run_last()
        end,
        desc = "Run Last",
      },
      {
        "<leader>do",
        function()
          require("dap").step_out()
        end,
        desc = "Step Out",
      },
      {
        "<leader>dO",
        function()
          require("dap").step_over()
        end,
        desc = "Step Over",
      },
      {
        "<leader>dp",
        function()
          require("dap").pause()
        end,
        desc = "Pause",
      },
      {
        "<leader>dr",
        function()
          require("dap").repl.toggle()
        end,
        desc = "Toggle REPL",
      },
      {
        "<leader>ds",
        function()
          require("dap").session()
        end,
        desc = "Session",
      },
      {
        "<leader>dt",
        function()
          require("dap").terminate()
        end,
        desc = "Terminate",
      },
      {
        "<leader>dw",
        function()
          require("dap.ui.widgets").hover()
        end,
        desc = "Widgets",
      },
      {
        "<leader>du",
        function()
          require("dapui").toggle({})
        end,
        desc = "Dap UI",
      },
      {
        "<leader>dU",
        function()
          require("dapui").toggle({ layout = 2, reset = true })
        end,
        desc = "Dap Console (maximize)",
      },
      {
        "<leader>de",
        function()
          require("dapui").eval()
        end,
        desc = "Eval",
        mode = { "n", "v" },
      },
      -- Note: <leader>dPt and <leader>dPc use LazyVim's default Python debug keybindings
    },
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "nvim-neotest/nvim-nio" },
  },
  {
    "theHamsta/nvim-dap-virtual-text",
    opts = {},
  },
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>d", group = "debug", icon = "󰃤" },
        { "<leader>dP", group = "Python", icon = "" },
      },
    },
  },
}