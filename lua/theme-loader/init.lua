local M = {}

M.setup = function(opts)
    local configs = require('theme-loader.configs')
    configs.setup(opts)
end

return M
