local M = {}
local Popup = require("nui.popup")
local event = require("nui.utils.autocmd").event

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
            vim.notify("Success Loaded")
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
    for i, _ in ipairs(themes) do
        vim.api.nvim_buf_set_lines(buf, i-1, -1, false, {
            " " .. unselected .. themes[i].name,
        })
    end
    M.handleKeys(buf)

    -- local row, col = unpack(vim.api.nvim_win_get_cursor(0))


    -- Make it read-only
    vim.api.nvim_set_option_value("modifiable", false, {})
    vim.api.nvim_set_option_value("buftype", "nofile", {})
end

return M
