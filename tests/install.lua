local ServerManager = require("dllm.server_manager")

vim.o.runtimepath = vim.fn.getcwd() .. "," .. vim.o.runtimepath

for pack, _ in pairs(package.loaded) do
  if pack:match("^dllm") then
    package.loaded[pack] = nil
  end
end

---@return ServerManager
local function get_manager()
  local config = {}
  return ServerManager.new(config)
end

local manager = get_manager()
if not manager:is_installed({ verbose = true }) then
  print("dllm is not installed")
  -- manager:install()
end


manager:start()
