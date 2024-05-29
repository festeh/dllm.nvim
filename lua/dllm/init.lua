local default_config = require("dllm.config")


local M = {}

M.setup = function(config)
    config = config or {}
    -- config = vim.tbl_deep_extend("force", default_config, config)
    -- M.init(config)
    require('telescope').load_extension('dllm')
end


M.reset = function()
    local to_kill = {"dllm", "telescope"}
    for mod, _ in pairs(package.loaded) do
        for _, name in ipairs(to_kill) do
            if mod:match(name) then
                package.loaded[mod] = nil
            end
        end
    end
end

return M
