local M = {}

function M.setup(themes)
    vim.cmd("vsplit") -- Open a vertical split
    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_get_current_win()

    vim.api.nvim_win_set_buf(win, buf)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
        themes[0],
    })
    vim.api.nvim_buf_set_lines(buf, 2, 10, false, {
        themes[2],
    })
    -- Make it read-only
    vim.api.nvim_set_option_value("modifiable", false, {})
    vim.api.nvim_set_option_value("buftype", "nofile", {})
end

return M
