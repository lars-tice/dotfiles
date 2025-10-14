-- Custom installer for debugpy that prefers uv over pip
local M = {}

-- Helper function to search upward for a directory
local function find_upward(start_path, target_dir)
  local path = start_path
  local root = vim.loop.os_homedir() or "/"

  while path ~= root and path ~= "/" do
    local candidate = path .. "/" .. target_dir
    if vim.fn.isdirectory(candidate) == 1 then
      return path
    end
    -- Move up one directory
    path = vim.fn.fnamemodify(path, ":h")
  end

  return nil
end

-- Helper function to get the correct Python path
function M.get_python_path()
  local cwd = vim.fn.getcwd()

  -- Search upward for .venv directory (uv's default)
  local venv_root = find_upward(cwd, ".venv")
  if venv_root then
    local uv_python = venv_root .. "/.venv/bin/python"
    if vim.fn.filereadable(uv_python) == 1 then
      return uv_python
    end
  end

  -- Search upward for traditional venv directory
  local trad_venv_root = find_upward(cwd, "venv")
  if trad_venv_root then
    local venv_python = trad_venv_root .. "/venv/bin/python"
    if vim.fn.filereadable(venv_python) == 1 then
      return venv_python
    end
  end

  -- Fall back to system python3
  return vim.fn.exepath("python3") ~= "" and vim.fn.exepath("python3") or vim.fn.exepath("python")
end

function M.ensure_debugpy()
  local cwd = vim.fn.getcwd()

  -- Search upward for pyproject.toml (might be in parent directory)
  local project_root = cwd
  local search_path = cwd
  local root = vim.loop.os_homedir() or "/"

  while search_path ~= root and search_path ~= "/" do
    if vim.fn.filereadable(search_path .. "/pyproject.toml") == 1 then
      project_root = search_path
      break
    end
    search_path = vim.fn.fnamemodify(search_path, ":h")
  end

  -- Only proceed if pyproject.toml was found
  if vim.fn.filereadable(project_root .. "/pyproject.toml") ~= 1 then
    -- No pyproject.toml found, do nothing
    return true
  end

  -- Check if uv is available
  local uv_path = vim.fn.exepath("uv")

  if uv_path == "" then
    vim.notify("uv not found, skipping debugpy installation", vim.log.levels.WARN)
    return false
  end

  -- Check if debugpy is already available using uv run (from project root)
  local check_cmd = string.format("cd '%s' && uv run python -c 'import debugpy' 2>/dev/null", project_root)
  local result = vim.fn.system(check_cmd)

  if vim.v.shell_error == 0 then
    -- debugpy is already installed
    return true
  end

  vim.notify("Installing debugpy with uv...", vim.log.levels.INFO)

  -- Use uv add --dev to install debugpy as a dev dependency (from project root)
  local install_cmd = string.format("cd '%s' && uv add --dev debugpy", project_root)
  vim.fn.system(install_cmd)

  if vim.v.shell_error == 0 then
    vim.notify("debugpy installed successfully with uv", vim.log.levels.INFO)
    return true
  else
    vim.notify("Failed to install debugpy with uv", vim.log.levels.ERROR)
    return false
  end
end

return M