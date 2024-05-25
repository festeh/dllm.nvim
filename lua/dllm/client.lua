local class = require("dllm.class")


local Client = class.new(function(self, config, input)
  self.config = config
  self.input = input
end)

function Client:respond()

end

return Client
