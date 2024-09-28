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

--- @class Chat
--- @field config Config
--- @field client_input ClientInput
--- @field new function
--- @field got_model_info boolean
Chat = class.new(function(self, config, client_input)
  self.config = config
  self.client_input = client_input
  self.got_model_info = false
end)

--- @return Chat | nil
Chat.from_file = function(config, opts)
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local client_input = ClientInput.from_chat(config, lines, opts)
  if client_input == nil then
    vim.notify("A dllm chat must be opened in the current buffer")
    return nil
  end
  return Chat.new(config, client_input)
end

function Chat:set_param(name, value)
  --- find first line starting with "---"
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local found = nil
  for i, line in ipairs(lines) do
    if line == "---" then
      found = i
      break
    end
  end
  if not found then
    return
  end
  local newline = name .. ": " .. value
  for i, line in ipairs(lines) do
    if i >= found then
      break
    end
    if line:find(name) then
      vim.api.nvim_buf_set_lines(0, i - 1, i, false, { newline })
      return
    end
  end
  vim.api.nvim_buf_set_lines(0, found - 1, found - 1, false, { newline })
end

function Chat:get_param(name)
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  for _, line in ipairs(lines) do
    local key, value = string.match(line, "^(.-):%s*(.+)$")
    if key == name then
      return value
    end
  end
  return nil
end

local function append_text(bufnr, text)
  local line = vim.api.nvim_buf_line_count(bufnr) - 1
  local col = vim.api.nvim_buf_get_lines(bufnr, line, line + 1, false)[1]:len()
  local lines = vim.split(text, "\n")
  vim.api.nvim_buf_set_text(bufnr, line, col, line, col, lines)
end


local function append_prefix(prefix)
  local lines = vim.api.nvim_buf_get_lines(0, -2, -1, false)
  if #lines == 0 or lines[1] ~= "" then
    vim.api.nvim_buf_set_lines(0, -1, -1, false, { "" })
  end
  vim.api.nvim_buf_set_lines(0, -1, -1, false, { prefix })
end

function Chat:get_on_start()
  return function()
    append_prefix(self.config.system_prefix)
  end
end

function Chat:get_on_exit()
  return function()
    append_prefix(self.config.user_prefix)
  end
end

function Chat:get_on_stdout_event()
  return function(data)
    if not self.got_model_info and string.find(data, "^dllm:") then
      local model_info = string.match(data, "^dllm:(.-)\n")
      local decoded = vim.fn.json_decode(model_info)
      print(vim.inspect(decoded))
      local model = decoded.model or "unknown model"
      local res = string.format(" (%s)", model)
      append_text(0, res)
      vim.api.nvim_buf_set_lines(0, -1, -1, false, { "" })
      self.got_model_info = true
      local lines = vim.split(data, "\n")
      if #lines > 1 then
        data = lines[2]
      else
        return
      end
    end
    append_text(0, data)
  end
end

local function on_stderr_event(data)
  append_text(0, data)
end

function Chat:respond()
  local server_manager = require("dllm.server_manager").new(self.config)
  if not server_manager:is_running() then
    server_manager:start()
  end
  local client_params = {
    input = self.client_input,
    on_start = self:get_on_start(),
    on_stdout_event = vim.schedule_wrap(self:get_on_stdout_event()),
    on_stderr_event = vim.schedule_wrap(on_stderr_event),
    on_exit = vim.schedule_wrap(self:get_on_exit())
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
