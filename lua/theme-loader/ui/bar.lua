local M = {}

function M.setup(themes)
    vim.cmd("vsplit") -- Open a vertical split
    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_get_current_win()

    vim.api.nvim_win_set_buf(win, buf)
    for i, _ in ipairs(themes) do
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
            themes[i].name,
        })
    end
    -- Make it read-only
    vim.api.nvim_set_option_value("modifiable", false, {})
    vim.api.nvim_set_option_value("buftype", "nofile", {})
end

return M
