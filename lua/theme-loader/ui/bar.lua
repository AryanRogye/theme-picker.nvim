local M = {}

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
        vim.api.nvim_buf_set_extmark(
            buf,
            ns_id,
            i - 1,
            1,
            {
                virt_text = { { " ", "NonText" } },
                virt_text_pos = "overlay",
            }
        )
    end


    -- Make it read-only
    vim.api.nvim_set_option_value("modifiable", false, {})
    vim.api.nvim_set_option_value("buftype", "nofile", {})
end

return M
