vim.api.nvim_create_user_command("Lmnewchat",
  function(_)
    local Chat = require('dllm.chat')
    local config = require('dllm.config')
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
    local Chat = require('dllm.chat')
    local config = require('dllm.config')
    local chat = Chat.from_file(config, opts)
    if chat == nil then
      return
    end
    chat:respond()
  end,
  {
    desc = "Get response from LLM provider using last N messages as a context",
    force = true,
  }
)

vim.api.nvim_create_user_command("Lmsetprovider",
  function(opts)
    local chat = Chat.from_file(config)
    if chat == nil then
      return
    end
  end,
  {
    desc = "Set the provider for the chat",
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
