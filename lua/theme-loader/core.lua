local M = {}
local storage = require("theme-loader.storage")

-- Function to save the theme inside the users data directory
function M.save_theme_state(index)
    local state_file = vim.fn.stdpath("data") .. "/theme_loader_state.json"

    -- Load existing state
    local file = io.open(state_file, "r")
    local data = file and vim.fn.json_decode(file:read("*a")) or {}
    if file then file:close() end

    -- Update only the last used theme index, keep other data
    data.last_index = index

    -- Write merged data back to file
    file = io.open(state_file, "w")
    if file then
        file:write(vim.fn.json_encode(data))
        file:close()
    else
        vim.notify("Failed to save theme state.", vim.log.levels.ERROR)
    end
end

-- Function retrieves the current theme from the user data directory
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

-- Main Function to Load Theme Configs
local function loadThemeConfigs(index, save)
    local theme = M.opts.themes[index]

    if not theme then
        vim.notify("Theme not found at index: " .. index, vim.log.levels.WARN)
        return
    end
    -- If the theme is found, then apply it
    theme.func()

    -- -- Load stored highlights for this theme's name
    local theme_name = theme.name
    storage.title = theme_name  -- so subsequent saves go under this theme
    local all_themes_data = storage.getAllThemesData()  -- a helper to fetch all themes data
    local this_theme_data = all_themes_data and all_themes_data[theme_name] or nil

    -- Apply the loaded highlight groups to the current session
    if this_theme_data then
        for group, props in pairs(this_theme_data) do
            vim.api.nvim_set_hl(0, group, props)
        end
    end

    -- save the theme index if selected
    if save then
        M.save_theme_state(index)  -- or however you store the last_index
    end
end



-- Function to Load A Theme
function M.loadTheme(index)
    loadThemeConfigs(index, true)
end

-- Function To Preview A Function Temporarily
function M.previewTheme(index)
    loadThemeConfigs(index, false)
end



-- Initial Setup Function
function M.setup(opts)
    M.opts = opts
end

return M
