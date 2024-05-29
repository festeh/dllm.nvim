local default_config = require("dllm.config")


local M = {}

M.setup = function(config)
    config = config or {}
    -- config = vim.tbl_deep_extend("force", default_config, config)
    -- M.init(config)
    require('telescope').load_extension('dllm')
end


-- M.init = function(config)
--     
-- end

M.ping = function()
    print("ping")
    print("ping")
end

return M
