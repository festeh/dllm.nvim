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
    local args = opts.args
    if args == "" or args == nil then
      args = 1
    end
    if not tonumber(args) or tonumber(args) == 0 then
      vim.notify("Argument must be a positive number", vim.log.levels.WARN)
      return
    end
    local Chat = require('dllm.chat')
    local config = require('dllm.config')
    opts.n_messages = tonumber(args)
    local chat = Chat.from_file(config, opts)
    if chat == nil then
      return
    end
    chat:respond()
  end,
  {
    desc = "Get response from LLM provider using last N messages as a context",
    force = true,
    nargs = "?",
  }
)

local function set_chat_param(name, value)
  local Chat = require('dllm.chat')
  local config = require('dllm.config')
  local chat = Chat.from_file(config)
  if chat == nil then
    return
  end
  chat:set_param(name, value)
end

local function get_chat_param(name)
  local Chat = require('dllm.chat')
  local config = require('dllm.config')
  local chat = Chat.from_file(config)
  if chat == nil then
    return
  end
  return chat:get_param(name)
end

local function add_match(matches, opt, ArgLead)
  if string.sub(opt, 1, string.len(ArgLead)) == ArgLead then
    table.insert(matches, opt)
  end
end

vim.api.nvim_create_user_command("Lmsetprovider",
  function(opts)
    set_chat_param("provider", opts.args)
  end,
  {
    desc = "Set the provider for the chat",
    force = true,
    nargs = 1,
    complete = function(ArgLead, CmdLine, CursorPos)
      local options = { "anthropic", "openai" }
      local matches = {}
      for _, opt in ipairs(options) do
        add_match(matches, opt, ArgLead)
      end
      return matches
    end,
  }
)

vim.api.nvim_create_user_command("Lmsetmodel",
  function(opts)
    set_chat_param("model", opts.args)
  end,
  {
    desc = "Set the model for the chat",
    force = true,
    nargs = 1,
    complete = function(ArgLead, CmdLine, CursorPos)
      local matches = {}
      local provider = get_chat_param("provider")
      local options = {}
      if provider == "openai" then
        options = { "gpt-4", "gpt-4o", "gpt-o1" }
      elseif provider == "anthropic" then
        options = { "claude-3-5-sonnet-20240620", "claude-3-opus-20240229" }
      end
      for _, opt in ipairs(options) do
        add_match(matches, opt, ArgLead)
      end
      return matches
    end,
  }
)

vim.api.nvim_create_user_command("Lmsettemperature",
  function(opts)
    if not tonumber(opts.args) then
      vim.notify("Temperature must be a number", vim.log.levels.WARN)
      return
    end
    set_chat_param("temperature", opts.args)
  end,
  {
    desc = "Set the context for the chat",
    force = true,
    nargs = 1,
  }
)

vim.api.nvim_create_user_command("Lmsetmaxtokens",
  function(opts)
    if not tonumber(opts.args) then
      vim.notify("Max tokens must be a number", vim.log.levels.WARN)
      return
    end
    set_chat_param("max_tokens", opts.args)
  end,
  {
    desc = "Set the context for the chat",
    force = true,
    nargs = 1,
  }
)

vim.api.nvim_create_user_command("Lminstallserver",
  function(opts)
    local config = require('dllm.config')
    local manager = require('dllm.server_manager').new(config)
    manager:install()
  end,
  {
    desc = "Update the dllm server for the chat",
    force = true,
  }
)

vim.api.nvim_create_user_command("Lmupdateserver",
  function(opts)
    local config = require('dllm.config')
    local manager = require('dllm.server_manager').new(config)
    manager:update()
  end,
  {
    desc = "Update the dllm server for the chat",
    force = true,
  }
)

local chat_path = require('dllm.paths').chats()
vim.api.nvim_create_autocmd({ "BufEnter", }, {
  pattern = { chat_path .. "/" .. "*.md", },
  desc = "Wrap lines in chat files",
  callback = function(ev)
    vim.api.nvim_command("setlocal wrap linebreak")
    vim.api.nvim_buf_set_keymap(0, "n", "<CR>", ":Lmrespond<CR>", { noremap = true, silent = true })
  end
})
