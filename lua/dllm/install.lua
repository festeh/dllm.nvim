local api = vim.api
local fn = vim.fn

local M = {}

local function get_dllm_path()
  return vim.fn.stdpath('data') .. '/dllm/dllm'
end


M.check_dllm_installed = function()
  local ok = vim.fn.filereadable(get_dllm_path()) == 1
  if not ok then
    return ok
  end
  ok = vim.fn.filereadable(get_dllm_path() .. '/build/server') == 1
  return ok
end

M.install_dllm = function()
  if M.check_dllm_installed() then
    vim.notify('dllm is already installed')
    return
  end
  local dllm_url = "https://github.com/festeh/dllm"
  local cmd = {
    "git", "clone",
    dllm_url,
    get_dllm_path()
  }
  local res = vim.system(cmd, { stdout = false }):wait()
  if res.code ~= 0 then
    vim.notify('Error:' .. res.stderr)
    return
  end
end


return M
