local class = require("dllm.class")

---@class ClientInput
---@field params table
---@field prompt string
---@field messages table
---@field new function
local ClientInput = class.new(function(self, params, prompt, messages)
  self.params = params
  self.prompt = prompt
  self.messages = messages
end)

--- Parsing the chat content
local function trim_left(s)
  return s:match("^%s*(.+)$")
end

ChatParsingContext = class.new(function(self, config)
  self.config = config
end)

local reading_user = 2
local reading_system = 4

function ChatParsingContext:read_message_fn()
  local state = reading_user
  local found_start = false
  local err = nil
  local config = self.config

  local function read_line(_, gathered, line)
    gathered.messages = gathered.messages or {}
    if state == reading_user then
      print(line:sub(1, #config.user_prefix), config.user_prefix)
      if line:sub(1, #config.user_prefix) == config.user_prefix then
        local user_message = trim_left(line:sub(#config.user_prefix + 1))
        gathered.messages[#gathered.messages + 1] = { role = "user", content = user_message }
        found_start = true
      elseif line:sub(1, #config.system_prefix) == config.system_prefix then
        if not found_start then
          err = "System message found before first user message"
          return nil, err
        end
        local system_message = trim_left(line:sub(#config.system_prefix + 1))
        gathered.messages[#gathered.messages + 1] = { role = "assistant", content = system_message }
        state = reading_system
      else
        gathered.messages[#gathered.messages].content = gathered.messages[#gathered.messages].content .. "\n" .. line
      end
    elseif state == reading_system then
      if line:sub(1, #config.user_prefix) == config.user_prefix then
        state = reading_user
        local user_message = trim_left(line:sub(#config.user_prefix + 1))
        gathered.messages[#gathered.messages + 1] = { role = "user", content = user_message }
      else
        gathered.messages[#gathered.messages].content = gathered.messages[#gathered.messages].content .. "\n" .. line
      end
    end
    return read_line
  end

  return read_line
end

function ChatParsingContext:read_params_line(gathered, line)
  gathered.params = gathered.params or {}
  if line == "---"
  then
    return self.read_message_fn(self), nil
  end
  local param, value = line:match("^(.+): (.+)$")
  if param and param == "role" then
    gathered.prompt = value
    return self.read_params_line, nil
  elseif param then
    gathered.params[param] = value
    return self.read_params_line, nil
  end
  return nil, "Invalid parameter line"
end

function ChatParsingContext:read_empty_line(gathered, line)
  if line == "" then
    return self.read_params_line, nil
  end
  return self:read_params_line(gathered, line), nil
end

function ChatParsingContext:read_title(gathered, line)
  local title = line:match("^Title: (.+)$")
  if title then
    gathered.title = title
    return self.read_empty_line, nil
  end
  return nil, "Title not found"
end

ClientInput.from_chat = function(config, lines, opts)
  local gathered = {}
  local context = ChatParsingContext.new(config)
  local proc_fn = context.read_title
  --- reading header
  print("lines", vim.inspect(lines))
  for _, line in ipairs(lines) do
    print("line", line)
    local new_fn, err = proc_fn(context, gathered, line)
    if not new_fn then
      vim.notify("Error: " .. err)
      return nil
    end
    proc_fn = new_fn
  end
  if gathered.prompt == nil then
    vim.notify("Warning: no prompt found")
  end
  gathered.prompt = gathered.prompt or ""
  opts = opts or {}
  if opts.n ~= nil then
    gathered.messages = { table.unpack(gathered.messages, #gathered.messages - opts.n + 1) }
  end
  return ClientInput.new(gathered.params, gathered.prompt, gathered.messages)
end

function ClientInput:to_request_body()
  local result = {}
  table.insert(result, { role = "system", content = self.prompt })
  for _, message in ipairs(self.messages) do
    table.insert(result, message)
  end
  return vim.json.encode({query = result})
end

--- End parsing chat content

return ClientInput
