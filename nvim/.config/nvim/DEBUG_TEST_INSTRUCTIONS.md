# Testing Python Debugging in Neovim

## Setup Instructions

1. **Open Neovim** and let Lazy.nvim install the new plugins:
   ```bash
   cd ~/.config/nvim
   nvim
   ```
   Lazy.nvim should automatically detect and install the new debugging plugins.

2. **Open the test file**:
   ```
   :e test_debug.py
   ```

## Testing Debugging Features

### Basic Debugging

1. **Set a breakpoint** on line 11 (inside calculate_factorial):
   - Place cursor on line 11
   - Press `<leader>db` to toggle breakpoint
   - You should see a red dot in the sign column

2. **Start debugging**:
   - Press `<leader>dc` to start debugging
   - On first run, nvim-dap-python will prompt to install debugpy - accept this

3. **Debug controls**:
   - `<leader>dO` - Step over (next line)
   - `<leader>di` - Step into function
   - `<leader>do` - Step out of function
   - `<leader>dc` - Continue execution
   - `<leader>dt` - Terminate debugging

### UI Features

- `<leader>du` - Toggle DAP UI (shows variables, stack, breakpoints)
- `<leader>de` - Evaluate expression under cursor
- `<leader>dr` - Toggle REPL for interactive debugging

### Python-Specific Features

- `<leader>dPt` - Debug test method (when cursor is on a test)
- `<leader>dPc` - Debug test class

## Verify Installation

Run this in Neovim to check if debugpy is available:
```
:lua print(vim.fn.executable('python3 -m debugpy'))
```

## Troubleshooting

1. If debugpy installation fails, you can install it manually:
   ```bash
   python3 -m pip install debugpy
   ```

2. Check DAP status:
   ```
   :lua print(vim.inspect(require('dap').status()))
   ```

3. View DAP log:
   ```
   :lua require('dap').set_log_level('DEBUG')
   ```

## Key Mappings Summary

- `<leader>d` - Debug prefix
- `<leader>db` - Toggle breakpoint
- `<leader>dc` - Continue/Start
- `<leader>du` - Toggle UI
- `<leader>dO` - Step over
- `<leader>di` - Step into
- `<leader>do` - Step out
- `<leader>dt` - Terminate