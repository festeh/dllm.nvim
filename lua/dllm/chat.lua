local paths = require("dllm.paths")
local class = require("dllm.class")
local ClientInput = require("dllm.client_input")



local function get_month(date)
  local months = {
    "jan", "feb", "mar", "apr", "may", "jun",
    "jul", "aug", "sep", "oct", "nov", "dec"
  }
  return months[date.month]
end

local function get_new_chat_filename()
  -- Use the current date and time to generate a new chat filename
  -- Example: 21_may_2021_12_30.md
  local date = os.date("*t")
  local filename = string.format(
    "%d_%s_%d_%d_%d.md",
    date.day,
    get_month(date),
    date.year,
    date.hour,
    date.min
  )
  return filename
end

local function get_new_chat_path()
  local filename = get_new_chat_filename()
  local chat_dir = paths.chats()
  if vim.fn.isdirectory(chat_dir) == 0 then
    vim.fn.mkdir(chat_dir, "p")
  end
  return chat_dir .. "/" .. filename
end

Chat = class.new(function(self, config)
  self.config = config
end)

function Chat:respond(opts)
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local client_input = ClientInput.from_chat(self.config, lines, opts)
  local client = require("dllm.client").new(self.config, client_input)
  client:respond()
end

Chat.create_file = function(config)
  local chat = Chat.new(config)

  local chat_path = get_new_chat_path()
  local chat_file = io.open(chat_path, "w")
  if chat_file == nil then
    return nil
  end
  chat_file:write(require("dllm.template").chat_template)
  chat_file:close()
  vim.cmd("edit " .. chat_path)
  -- find the line starting with "role:"
  -- and place the cursor at the end of the line
  vim.cmd [[/^role:/]]
  vim.cmd [[normal! $]]
  vim.cmd [[nohlsearch]]
  return chat
end

return Chat
