vim.o.runtimepath = vim.fn.getcwd() .. "," .. vim.o.runtimepath

for pack, _ in pairs(package.loaded) do
  -- print("pack", pack)
  if pack:match("^dllm") then
    print("unloading", pack)
    package.loaded[pack] = nil
  end
end

local ClientInput = require("dllm.client_input")
local Client = require("dllm.client")

local config = {
  hostname = "localhost",
  port = 4242,
  provider = "dummy",
}

--- @type ClientInput
local client_input = ClientInput.new({}, "hi!", { {
  role = "user",
  content = "ping",
} })

--- @type Client
local client = Client.new(config, client_input)
local res = client:respond()
print("response:", res)
res:wait()
print("done")
