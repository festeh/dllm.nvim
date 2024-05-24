local class = require("dllm.class")


local ClientInput = class.new(function(self, config, prompt, messages)
  self.config = config
  self.prompt = prompt
  self.messages = messages
end)

ClientInput.from_chat = function (content)

end


return ClientInput
