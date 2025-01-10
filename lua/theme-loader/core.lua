local M = {}

function M.save_theme_state(index)
    local state_file = vim.fn.stdpath("data") .. "/theme_loader_state.json"
    local state = { last_index = index }
    local file = io.open(state_file, "w")
    if file then
        file:write(vim.fn.json_encode(state))
        file:close()
    else
        vim.notify("Failed to save theme state.", vim.log.levels.ERROR)
    end
end

function M.load_theme_state()
    local state_file = vim.fn.stdpath("data") .. "/theme_loader_state.json"
    local file = io.open(state_file, "r")
    if file then
        local content = file:read("*a")
        file:close()
        local state = vim.fn.json_decode(content)
        return state.last_index
    else
        return nil
    end
end

function M.Lt(index)
    local theme = M.opts.themes[index]
    if theme then
        theme.func()
        M.save_theme_state(index) -- Save the theme index
    else
        vim.notify("Theme not found at index: " .. index, vim.log.levels.WARN)
    end
end

function M.load_theme_by_ui(index)
    require("theme-loader.ui.bar").setup(M.keys,M.opts.config,M.opts.themes, index)
end

function M.load_theme_by_index()
    local str = vim.fn.input("> ")
    local strI = tonumber(str)
    if strI then
        M.Lt(strI)
    else
        vim.notify("Invalid input! Please enter a number.", vim.log.levels.WARN)
    end
end

function M.setup(opts)
    M.opts = opts
end

return M
