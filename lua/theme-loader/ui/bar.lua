local M = {}

function M.checkDeviIcon()
    local devicons_ok, devicons = pcall(require, "nvim-web-devicons")
    if not devicons_ok then
        return false
    end
    return devicons
end

function M.setup(themes)
    vim.cmd("split")
    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_get_current_win()

    local icon = ""
    local selected = "[X]"
    local unselected = "[]"

    local devicons = M.checkDeviIcon()
    if devicons then
        icon = devicons.get_icon("init.vim", "vim", { default = true })
    end

    vim.api.nvim_win_set_buf(win, buf)
    for i, _ in ipairs(themes) do
        vim.api.nvim_buf_set_lines(buf, i-1, -1, false, {
            icon .. unselected .. themes[i].name,
        })
    end
    -- Make it read-only
    vim.api.nvim_set_option_value("modifiable", false, {})
    vim.api.nvim_set_option_value("buftype", "nofile", {})
end

return M
