local M = {}


-- Start
M.setup = function(opts)
    local configs = require('theme-loader.configs')
    -- setup with the configs
    configs.setup(opts)
end

return M
