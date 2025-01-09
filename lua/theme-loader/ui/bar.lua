local M = {}

function M.setup(themes)
    vim.cmd("vsplit") -- Open a vertical split
    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_get_current_win()

    vim.api.nvim_win_set_buf(win, buf)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
        "Theme Picker Sidebar",
        "1. GruvBox",
        "2. Oxocarbon",
        "3. Cyberdream",
    })

    -- Make it read-only
    vim.api.nvim_buf_set_option(buf, "modifiable", false)
    vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
end

return M
