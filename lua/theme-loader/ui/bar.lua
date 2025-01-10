local M = {}

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
            require('theme-loader.core').load_theme_by_ui(row)
        end
    })
    vim.api.nvim_buf_set_keymap(buf, "n", "q", "", {
        noremap = true,
        silent = true,
        callback = function()
            vim.api.nvim_set_option_value("modifiable", true, {})
            vim.api.nvim_buf_delete(buf, { force = true })
        end
    })
    vim.api.nvim_create_autocmd("BufWipeout", {
        buffer = buf,
        callback = function()
            vim.api.nvim_set_option_value("modifiable", true, {})
        end,
    })
end
function M.checkBufOpen(buf_name)
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf) then
            local name = vim.api.nvim_buf_get_name(buf)
            if name == buf_name then
                return buf
            end
        end
    end
    return nil
end
function M.setup(config, themes, loc)
    local buf_name = "theme-loader"
    local existing_buf = M.checkBufOpen(buf_name)
    if existing_buf then
        -- Focus the existing buffer
        vim.api.nvim_set_option_value("modifiable", true, {})
        vim.api.nvim_buf_delete(existing_buf, { force = true })
        return
    end

    vim.cmd("vsplit")
    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_get_current_win()
    vim.api.nvim_buf_set_name(buf, buf_name)
    vim.api.nvim_buf_set_name(buf, buf_name)
    vim.cmd("vertical resize " .. config.ui_col_spacing )

    local selected = config.opening .. config.selection .. config.closing
    local unselected = config.opening .. " " .. config.closing
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

    -- Get the col location based on the opening size
    local colLoc = #config.opening + 1

    -- Move the cursor to the last place if one
    if loc and loc > 0 and loc <= #themes then
        vim.api.nvim_win_set_cursor(win, { loc, colLoc }) -- {row, column}
    else
        vim.api.nvim_win_set_cursor(win, { 1, 0 }) -- Default to the first row
    end
end

return M
