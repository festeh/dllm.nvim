
local M = {}

M.plugin_base = function()
  return vim.fn.stdpath('data') .. '/dllm.nvim'
end

M.dllm_repo = function()
  return M.plugin_base() .. '/dllm'
end

M.dllm_server = function()
  return M.dllm_repo() .. '/build/dllm_server'
end

M.chats = function()
  return M.plugin_base() .. '/chats'
end


M.exists = function(path)
  return vim.fn.filereadable(path)
end


return M
