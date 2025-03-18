local M = {}

-- Function to load a theme by an actual UI
function M.load_theme_by_ui(index)
    require("theme-loader.ui.theme_selector").setup(M.opts.config,M.opts.themes, index)
end

-- Function to load a theme by an index
function M.load_theme_by_index()
    local str = vim.fn.input("> ")
    local strI = tonumber(str)
    if strI then
        require("theme-loader.core").loadTheme(strI)
    else
        vim.notify("Invalid input! Please enter a number.", vim.log.levels.WARN)
    end
end


function M.load_color_picker()
    require("theme-loader.ui.theme_editor").setup(M.opts)
end


function M.register_commands()
    vim.api.nvim_create_user_command("SaveThemeState", function()
        print("Saving theme state")
        require("theme-loader.storage").saveState()
    end, {})
    vim.api.nvim_create_user_command("ResetThemeState", function()
        local storage = require("theme-loader.storage")
        storage.resetThemeByIndex(M.opts)
    end, {})
end


function M.setup(opts)
    M.opts = opts
    M.register_commands()
end

return M
