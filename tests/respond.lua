  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local client_input = ClientInput.from_chat(self.config, lines, opts)
  local client = require("dllm.client").new(self.config, client_input)
  client:respond()
