local class = require("dllm.class")
local paths = require("dllm.paths")

--- @class ServerManager
--- @field new function
local ServerManager = class.new(function(self, config)
  self.config = config
end)

function ServerManager:is_installed()
  return vim.fn.exepath(paths.dllm_server()) ~= ""
end

function ServerManager:update()
  vim.notify('Updating dllm')
  local pull_cmd = {
    "git",
    "-C",
    paths.dllm_repo(),
    "pull"
  }
  local res = vim.system(pull_cmd):wait()
  if res.code ~= 0 then
    vim.notify('Error updating dllm repo:' .. res.stderr)
    return
  end
  vim.notify('dllm repo updated')
  vim.notify('Building dllm server')
  local cmd = {
    "make",
    "-C",
    paths.dllm_repo(),
    "install_server"
  }
  res = vim.system(cmd):wait()
  if res.code ~= 0 then
    vim.notify('Error building dllm server:' .. res.stderr)
    return
  end
  vim.notify('dllm server built')
end

function ServerManager:install()
  vim.notify('Installing dllm')
  if self:is_installed() then
    vim.notify('dllm is already installed')
    return
  end
  print(paths.exists(paths.dllm_repo()))
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
  end
  self:update()
end

function ServerManager:is_running()
  local res = vim.system({ "pgrep", "dllm_server" }):wait()
  return res.code == 0
end

function ServerManager:start()
  vim.notify('Starting dllm server')
  if not self:is_installed() then
    vim.notify('dllm is not installed')
    return
  end
  local cmd = {
    paths.dllm_server(),
  }
  self.job = vim.fn.jobstart(cmd, {
    on_exit = function(_, code)
      if code ~= 0 then
        vim.notify('dllm server exited with code ' .. code)
      end
      vim.notify('dllm server exited')
    end
  })
  vim.notify('dllm server started')
end

return ServerManager
