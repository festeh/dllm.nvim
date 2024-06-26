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
local function trim(s)
  return s:match("^%s*(.-)%s*$")
end

ChatParsingContext = class.new(function(self, config)
  self.config = config
end)

function ChatParsingContext:read_message_fn()
  local found_start = false
  local config = self.config
  local function read_line(_, gathered, line)
    gathered.messages = gathered.messages or {}
    if line == "" then
      return read_line, nil
    end
    if line:sub(1, #config.user_prefix) == config.user_prefix then
      local msg = line:sub(#config.user_prefix + 1)
      gathered.messages[#gathered.messages + 1] = { role = "user", content = msg }
      found_start = true
    elseif line:sub(1, #config.system_prefix) == config.system_prefix then
      if not found_start then
        return nil, "System message found before first user message"
      end
      -- assume that system message is always below system prefix
      local msg = ""
      gathered.messages[#gathered.messages + 1] = { role = "assistant", content = msg }
    else
      if #gathered.messages == 0 then
        return nil, "No user message found"
      end
      gathered.messages[#gathered.messages].content = gathered.messages[#gathered.messages].content .. "\n" .. line
    end
    return read_line, nil
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
  if not title then
    vim.notify("Title for chat not found", vim.log.levels.WARN)
    title = ""
  end
  gathered.title = title
  return self.read_empty_line, nil
end

ClientInput.from_chat = function(config, lines, opts)
  local gathered = {}
  local context = ChatParsingContext.new(config)
  local proc_fn = context.read_title
  --- reading header
  for _, line in ipairs(lines) do
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
  for _, message in ipairs(gathered.messages) do
    message.content = trim(message.content)
  end
  if not opts.n_messages then
    opts.n_messages = 1
  end
  local filtered_messages = {}
  local user_messages_count = 0
  for i = #gathered.messages, 1, -1 do
    table.insert(filtered_messages, 1, gathered.messages[i])
    if gathered.messages[i].role == "user" then
      user_messages_count = user_messages_count + 1
      if user_messages_count >= opts.n_messages then
        break
      end
    end
  end
  gathered.messages = filtered_messages

  return ClientInput.new(gathered.params, gathered.prompt, gathered.messages)
end

function ClientInput:to_request_body()
  local messages = {}
  table.insert(messages, { role = "system", content = self.prompt })
  for _, message in ipairs(self.messages) do
    table.insert(messages, message)
  end
  local params = {}
  for _, name in ipairs({ "model", "temperature", "max_tokens" }) do
    if self.params[name] then
      params[name] = self.params[name]
      if name == "temperature" or name == "max_tokens" then
        params[name] = tonumber(params[name])
      end
    end
  end
  params["source"] = "dllm.nvim"
  return vim.json.encode({ messages = messages, parameters = params })
end

--- End parsing chat content

return ClientInput
