local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values

local Paths = require("dllm.paths")

local function get_file(line)
  local i = string.find(line, ":")
  if i == nil then
    return ""
  end
  return string.sub(line, 1, i - 1)
end

local function strip_file(line)
  local i = string.find(line, ":")
  if i == nil then
    return line
  end
  return string.sub(line, i + 1)
end

local endswith = function(str, ending)
  return ending == "" or str:sub(- #ending) == ending
end

kSplitter = '[__SPLITTER__]'

local function reduce(lines)
  local res = {}
  for _, line in ipairs(lines) do
    local file = get_file(line)
    if not endswith(file, ".md") then
      goto continue
    end
    if #res == 0 or get_file(res[#res]) ~= file then
      table.insert(res, line)
    else
      res[#res] = res[#res] .. kSplitter .. strip_file(line)
    end
    ::continue::
  end
  return res
end

local chats = function(opts)
  local default_opts = {
    prompt_title = "Find your chat",
    layout_strategy = "horizontal",
    layout_config = {
      height = 0.9,
      prompt_position = "bottom",
      preview_width = 0.4,
    },
  }
  opts = opts or {}
  opts = vim.tbl_extend("force", default_opts, opts)
  local cwd = Paths.chats()
  local cmd = { "rg", "Title:|role:" }
  local res = vim.system(cmd, { cwd = cwd, text = true }):wait()
  local results = vim.split(res.stdout, "\n")
  local reduced = reduce(results)
  local finder = finders.new_table {
    results = reduced,
    entry_maker = function(line)
      local file = get_file(line)
      line = strip_file(line)
      local parts = vim.split(line, kSplitter, { plain = true })
      line = parts[1] .. "; " .. parts[2]
      local full_path = cwd .. "/" .. file
      return {
        value = line,
        display = line,
        ordinal = line,
        filename = full_path,
      }
    end,
  }
  pickers.new(opts, {
    finder = finder,
    previewer = conf.file_previewer(opts),
    sorter = conf.generic_sorter(opts),
  }):find()
end

return require("telescope").register_extension {
  setup = function(ext_config, config)
    -- access extension config and user config
  end,
  exports = {
    dllm = chats,
  }
}
