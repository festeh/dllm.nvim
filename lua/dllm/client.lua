local class = require("dllm.class")
local curl = require("plenary.curl")

---@class Client
---@field config Config
---@field input ClientInput
---@field new function
Client = class.new(function(self, config, input)
  self.config = config
  self.input = input
end)

function Client:respond()
  local host = self.config.hostname or "localhost"
  local port = self.config.port
  local prov = self.config.provider or "dummy"
  local url = "http://" .. host .. ":" .. port .. "/" .. prov
  local input = self.input
  print("Sending request to " .. url)
  local res = curl.request({
    url = url,
    timeout = 10000,
    method = "POST",
    body = input:to_request_body(),
    headers = {
      ["Content-Type"] = "application/json",
    },
    callback = vim.schedule_wrap(function(response)
      print("Response status: " .. response.status)
      local data = response.body
      print("Size", #data)
    end),
  })
  return res
end

return Client
