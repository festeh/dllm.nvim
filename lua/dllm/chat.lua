local paths = require("dllm.paths")


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

local function get_chat_dir()
  local chat_dir = paths.chats()
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
  local template = require("dllm.template").chat_template
  chat:write(template)
  chat:close()
  vim.cmd("edit " .. path)
  -- find the line starting with "role:"
  -- and place the cursor at the end of the line
  vim.cmd [[/^role:/]]
  vim.cmd [[normal! $]]
  vim.cmd [[nohlsearch]]
  return chat
end

return M
