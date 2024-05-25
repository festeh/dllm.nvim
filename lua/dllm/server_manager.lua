local class = require("dllm.class")
local paths = require("dllm.paths")

--- @class ServerManager
--- @field new function
local ServerManager = class.new(function(self, config)
  self.config = config
end)

function ServerManager:is_installed(opts)
  return vim.fn.exepath(paths.dllm_server()) ~= ""
end

function ServerManager:install()
  vim.notify('Installing dllm')
  if self:is_installed() then
    vim.notify('dllm is already installed')
    return
  end
  if not paths.exists(paths.dllm_repo()) then
    vim.notify('Cloning dllm repo')
    local dllm_url = "https://github.com/festeh/dllm"
    local cmd = {
      "git", "clone",
      dllm_url,
      paths.dllm_repo()
    }
    local res = vim.system(cmd):wait()
    if res.code ~= 0 then
      vim.notify('Error cloning dllm repo:' .. res.stderr)
      return
    end
    vim.notify('dllm repo cloned')
  else
    vim.notify('Updating dllm repo')
    local cmd = {
      "git",
      "-C",
      paths.dllm_repo(),
      "pull"
    }
    local res = vim.system(cmd):wait()
    if res.code ~= 0 then
      vim.notify('Error updating dllm repo:' .. res.stderr)
      return
    end
    vim.notify('dllm repo updated')
  end
  vim.notify('Building dllm server')
  local cmd = {
    "make",
    "-C",
    paths.dllm_repo(),
    "install_server"
  }
  local res = vim.system(cmd):wait()
  if res.code ~= 0 then
    vim.notify('Error building dllm server:' .. res.stderr)
    return
  end
  vim.notify('dllm server built')
end

return ServerManager
