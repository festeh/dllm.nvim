local class = require("dllm.class")
local curl = require("plenary.curl")

--- @param config Config
local Client = class.new(function(self, config, input)
  self.config = config
  self.input = input
end)

function Client:respond()
  local host = self.config.hostname
  local port = self.config.port
  local prov = self.config.default_provider
  local url = "http://" .. host .. ":" .. port .. "/" .. prov
  curl.request({
    url = url,
    method = "POST",
    data = self.input:to_json(),
    headers = {
      ["Content-Type"] = "application/json",
    },
    callback = function(_, _, response)
      local data = vim.fn.json_decode(response.body)
      if data.error then
        print("Error: " .. data.error)
      else
        print(data.response)
      end
    end,
  })

end

return Client
