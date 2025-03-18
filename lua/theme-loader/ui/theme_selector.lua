local M = {}

function M.getCurrentThemeIndex()
    return require("theme-loader.core").load_theme_state()
end

function M.previewHandler(buf)
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    if not row or not col then
        vim.notify("There Was An Error", vim.og.levels.WARN)
    end

    require("theme-loader.core").previewTheme(row)
    -- Close The Current Buffer And Open it Again
    vim.api.nvim_buf_delete(buf, { force = true })
    require('theme-loader.commands').load_theme_by_ui(row)
end

function M.handleKeys(buf, config, themes)
    -- using the themes to get the actual size of the themes
    vim.api.nvim_buf_set_keymap(buf, "n", "<CR>", "", {
        noremap = true,
        silent = true,
        callback = function()
            local row, col = unpack(vim.api.nvim_win_get_cursor(0))
            if not row or not col then
                vim.notify("There Was An Error", vim.log.levels.WARN)
                return
            end
            require("theme-loader.core").loadTheme(row)
            -- Close The Current Buffer And Open it Again
            vim.api.nvim_buf_delete(buf, { force = true })
            require('theme-loader.commands').load_theme_by_ui(row)
        end
    })
    vim.api.nvim_buf_set_keymap(buf, "n", "q", "", {
        noremap = true,
        silent = true,
        callback = function()
            if config.preview then
                local selectedIndex = M.getCurrentThemeIndex()
                require("theme-loader.core").loadTheme(selectedIndex)
            end
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
    -- Block off these two keys so that you cant move left and right, tbh if the users h and l are not left and right
    -- then it will be overwritten and they will be allowed to move left and right
    vim.api.nvim_buf_set_keymap(buf, "n", "h", "", { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(buf, "n", "l", "", { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(buf, "n", "p", "", { noremap = true, silent = true, callback = function()
        config.preview = not config.preview
        require("theme-loader.core").loadTheme(M.getCurrentThemeIndex())
    end})

    -- Preview Handlers
    if config.preview then
        vim.api.nvim_buf_set_keymap(buf, "n", "j", "", {
            noremap = true,
            silent = true,
            callback = function()
                -- Current Row and Column
                local row, col = unpack(vim.api.nvim_win_get_cursor(0))
                local theme_lines = #themes
                if row < theme_lines then
                    vim.api.nvim_win_set_cursor(0, { row + 1, col })
                else
                    vim.api.nvim_win_set_cursor(0, { 1, col }) -- Wrap to top
                end
                M.previewHandler(buf)
            end
        })
        vim.api.nvim_buf_set_keymap(buf, "n", "k", "", {
            noremap = true,
            silent = true,
            callback = function()
                -- Current Row and Column
                local row, col = unpack(vim.api.nvim_win_get_cursor(0))
                local theme_lines = #themes
                if row > 1 then
                    vim.api.nvim_win_set_cursor(0, { row - 1, col })
                else
                    vim.api.nvim_win_set_cursor(0, { theme_lines, col })
                end
                M.previewHandler(buf)
            end
        })
    end

end

function M.drawThemes(themes, config, buf)
    local selected = config.opening .. config.selection .. config.closing
    local unselected = config.opening .. " " .. config.closing
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
end

function M.drawMenu(themes, config, buf)
    -- First Step is Getting The Row Height
    local rowLen = #themes
    local bar = string.rep("-", config.ui_col_spacing)
    vim.api.nvim_set_option_value("modifiable", true, {})


    -- Merge everything into a single list
    local lines = { bar } -- Start with the separator
    table.insert(lines, "q or :q quit") -- Add exit message

    -- Now 'lines' is a proper table of strings, no nested tables
    vim.api.nvim_buf_set_lines(buf, rowLen + 1, -1, false, lines)

    vim.api.nvim_set_option_value("modifiable", false, {})
end


-- Starting Point of the Theme Picker Menu
function M.setup(config, themes, loc)
    vim.cmd("vsplit")
    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_get_current_win()

    vim.cmd("vertical resize " .. config.ui_col_spacing)


    vim.api.nvim_win_set_buf(win, buf)
    M.drawThemes(themes, config, buf)
    M.drawMenu(themes,config,buf)
    M.handleKeys(buf, config, themes)

    vim.api.nvim_set_option_value("buftype", "nofile", {})

    -- Get the col location based on the opening size
    local colLoc = #config.opening + 1
    -- Move the cursor to the last place if one
    if loc and loc > 0 and loc <= #themes then
        vim.api.nvim_win_set_cursor(win, { loc, colLoc }) -- {row, column}
    else
        vim.api.nvim_win_set_cursor(win, { 1, colLoc }) -- Default to the first row
    end
end

return M
