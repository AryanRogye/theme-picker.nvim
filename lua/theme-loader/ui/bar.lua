local M = {}
local Popup = require("nui.popup")
local event = require("nui.utils.autocmd").event



function M.getCurrentThemeIndex()
    return require("theme-loader.core").load_theme_state()
end

function M.handleKeys(buf)
    vim.api.nvim_buf_set_keymap(buf, "n", "<CR>", "", {
        noremap = true,
        silent = true,
        callback = function()
            local row, col = unpack(vim.api.nvim_win_get_cursor(0))
            if not row or not col then
                vim.notify("There Was An Error", vim.log.levels.WARN)
                return
            end
            require("theme-loader.core").Lt(row)
            -- Close The Current Buffer And Open it Again
            vim.api.nvim_buf_delete(buf, { force = true })
            require('theme-loader.core').load_theme_by_ui()
        end
    })
end
function M.setup(themes)
    vim.cmd("split")
    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_get_current_win()

    local selected = "[X]"
    local unselected = "[ ]"
    local ns_id = vim.api.nvim_create_namespace("theme_picker_namespace")

    vim.api.nvim_win_set_buf(win, buf)
    vim.api.nvim_set_option_value("modifiable", true, {})
    for i, _ in ipairs(themes) do
        local sel = unselected
        if i == M.getCurrentThemeIndex() then
            sel = selected
        end
        vim.api.nvim_buf_set_lines(buf, i-1, -1, false, {
            " " .. sel .. themes[i].name,
        })
    end
    vim.api.nvim_set_option_value("modifiable", false, {})
    M.handleKeys(buf)

    vim.api.nvim_set_option_value("buftype", "nofile", {})
end

return M
