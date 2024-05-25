
local content = vim.api.nvim_buf_get_lines(0, 0, -1, false)
print(vim.inspect(content))
