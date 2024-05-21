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
end

local function get_chat_dir()
  local chat_dir = vim.fn.stdpath("data") .. "/dllm/chats"
  if vim.fn.isdirectory(chat_dir) == 0 then
    vim.fn.mkdir(chat_dir, "p")
  end
  return chat_dir
end

local M = {}

M.new_chat = function()
  local dir = get_chat_dir()
  local filename = get_new_chat_filename()
  local path = dir .. "/" .. filename
  local chat = io.open(path, "w")
  if chat == nil then
    return nil
  end
  chat:write("# Chat\n\n")
  chat:close()
  vim.cmd("edit " .. path)
  return chat
end

return M
