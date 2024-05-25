local Chat = require('dllm.chat')
local config = require('dllm.config')


vim.api.create_user_command("dnewchat",
  function(args)
    Chat:create_file(config)
  end,
  {
    desc = "Create a new chat file",
    force = true,
  }
)
