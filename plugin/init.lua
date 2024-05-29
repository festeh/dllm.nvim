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

local chat_path = require('dllm.paths').chats()
vim.api.nvim_create_autocmd({ "BufEnter", }, {
  pattern = { chat_path .. "/" .. "*.md", },
  desc = "Wrap lines in chat files",
  callback = function(ev)
    vim.api.nvim_command("setlocal wrap linebreak")
  end
})
