local ClientInput = require("dllm.client_input")


local inp = ClientInput.from_chat("hello")
print(inp.prompt)


