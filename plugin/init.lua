local Chat = require('dllm.chat')
local config = require('dllm.config')


vim.api.nvim_create_user_command("Lmnewchat",
  function(_)
    Chat.create_file(config)
  end,
  {
    desc = "Create a new chat file",
    force = true,
  }
)

vim.api.nvim_create_user_command("Lmfindchat",
  function(opts)
    require("telescope").extensions.dllm.dllm(opts)
  end,
  {
    desc = "Find a chat file",
    force = true,
  }
)

vim.api.nvim_create_user_command("Lmrespond",
  function(opts)
    local chat = Chat.new(config)
    chat:respond(opts)
  end,
  {
    desc = "Get response from LLM provider using last N messages as a context",
    force = true,
  }
)

