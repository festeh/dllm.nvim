local paths = require("dllm.paths")
local class = require("dllm.class")
local ClientInput = require("dllm.client_input")
local Client = require("dllm.client")


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

local function on_start()
  print("start")
end

local function append_text(bufnr, text)
  local line = vim.api.nvim_buf_line_count(bufnr) - 1
  local col = vim.api.nvim_buf_get_lines(bufnr, line, line + 1, false)[1]:len()
  local lines = vim.split(text, "\n")
  vim.api.nvim_buf_set_text(bufnr, line, col, line, col, lines)
end

local function on_stdout_event(data)
  --- append data to the current buffer
  append_text(0, data)
  print("stdout", data)
end

local function on_stderr_event(data)
  append_text(0, data)
  print("stderr", data)
end

local function on_exit(code)
  print("exit", code)
end

function Chat:respond(opts)
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local client_input = ClientInput.from_chat(self.config, lines, opts)
  local client_params = {
    input = client_input,
    on_start = on_start,
    on_stdout_event = vim.schedule_wrap(on_stdout_event),
    on_stderr_event = vim.schedule_wrap(on_stderr_event),
    on_exit = vim.schedule_wrap(on_exit),
  }
  local client = Client.init(self.config, client_params)
  client:respond()
end

Chat.init_buf = function()
  vim.api.nvim_command("setlocal wrap linebreak")
end

Chat.create_file = function(config)
  local chat = Chat.new(config)

  local chat_path = get_new_chat_path()
  local chat_file = io.open(chat_path, "w")
  if chat_file == nil then
    return nil
  end
  chat_file:write(require("dllm.template").chat_template)
  chat_file:write(config.user_prefix .. " ")
  chat_file:close()
  vim.cmd("edit " .. chat_path)
  -- find the line starting with "role:"
  -- and set the cursor to append to line mode
  vim.cmd [[/^role:/]]
  vim.cmd [[nohlsearch]]
  vim.cmd [[startinsert!]]

  Chat.init_buf()
  return chat
end

return Chat
