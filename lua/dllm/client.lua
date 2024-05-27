local class = require("dllm.class")
local Curl = require("dllm.curl")

---@class ClientParams
---@field input ClientInput
---@field on_start function | nil
---@field on_stdout_event function | nil
---@field on_stderr_event function | nil
---@field on_exit function | nil

---@class Client
---@field config Config
---@field params ClientParams
---@field new function
Client = class.new(function(self, config, params)
  self.config = config
  self.params = params
end)

--- @return Client
--- @param config Config
--- @param params ClientParams
function Client.init(config, params)
  return Client.new(config, params)
end

function Client:respond()
  local host = self.config.hostname or "localhost"
  local port = self.config.port
  local prov = self.config.provider or "dummy"
  local url = "http://" .. host .. ":" .. port .. "/" .. prov
  local input = self.params.input
  print("Sending request to " .. url)
  local curl_args = {
    url = url,
    body = input:to_request_body(),
  }
  curl_args = vim.tbl_extend("force", curl_args, self.params)
  local res = Curl.request(self.config, curl_args)
  return res
end

return Client
