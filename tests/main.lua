vim.o.runtimepath = vim.fn.getcwd() .. "," .. vim.o.runtimepath

for pack, _ in pairs(package.loaded) do
  if pack:match("^dllm") then
    package.loaded[pack] = nil
  end
end

local m = require("dllm")
local chat = require("dllm.chat")

chat.new_chat()
