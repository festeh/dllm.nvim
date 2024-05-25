local Chat = require('dllm.chat')
local config = require('dllm.config')


vim.api.nvim_create_user_command("lmnewchat",
  function(_)
    Chat.create_file(config)
  end,
  {
    desc = "Create a new chat file",
    force = true,
  }
)

vim.api.nvim_create_user_command("lmrespond",
  function(opts)
    local chat = Chat.new(config)
    chat:respond(opts)
  end,
  {
    desc = "Get response from LLM provider using last N messages as a context",
    force = true,
  }
)
