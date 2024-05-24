local ClientInput = require("dllm.client_input")


local input =
[[Title: hello

params1: too
role: You are a clown
tmp: 1.11
---
> Ping
and pong
< Pong
]]

local config = {
  user_prefix = ">",
  system_prefix = "<"
}

local inp = ClientInput.from_chat(config, input)
if inp == nil then
  vim.notify("Failed to parse input")
  return
end

print(vim.inspect(inp))
