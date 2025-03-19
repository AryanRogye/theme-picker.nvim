local M = {}

M.changed_highlights = {}  -- Stores the *current theme's* changes
M.title = ""               -- Stores the *current theme name*

function M.saveState()
    local state_file = vim.fn.stdpath("data") .. "/theme_loader_state.json"

    -- 1) Load existing data
    local file = io.open(state_file, "r")
    local data = file and vim.fn.json_decode(file:read("*a")) or {}
    if file then file:close() end

    -- 2) Ensure "themes" is a subtable
    data.themes = data.themes or {}

    -- 3) If we have a valid theme name, store changes under that theme
    if M.title and M.title ~= "" then
        data.themes[M.title] = vim.tbl_extend(
            "force",
            data.themes[M.title] or {},  -- existing changes
            M.changed_highlights         -- new changes
        )
        -- Mark this theme as selected
        data.selected_theme = M.title
    end

    -- Debug
    print("Saving theme:", M.title)
    print("New changes for this theme:", vim.inspect(M.changed_highlights))
    print("All themes after merge:", vim.inspect(data.themes))

    -- 4) Write merged data back to file
    file = io.open(state_file, "w")
    if file then
        file:write(vim.fn.json_encode(data))
        file:close()
        vim.notify("Theme changes saved successfully!", vim.log.levels.INFO)
    else
        vim.notify("Failed to save theme state.", vim.log.levels.ERROR)
    end
end

function M.loadState()
    local state_file = vim.fn.stdpath("data") .. "/theme_loader_state.json"
    local file = io.open(state_file, "r")

    if not file then return end

    local content = file:read("*a")
    file:close()

    local data = vim.fn.json_decode(content)
    if data then
        local theme = data.selected_theme
        M.title = theme or ""
        M.changed_highlights = {}

        -- If there's a valid theme name and table of changes, load them
        if theme and data.themes and data.themes[theme] then
            M.changed_highlights = data.themes[theme] or {}
        end

        M.last_index = data.last_index or nil

        vim.notify(
            string.format("Loaded theme state. Active theme: %s", M.title ~= "" and M.title or "None"),
            vim.log.levels.INFO
        )
    end
end

function M.getAllThemesData()
    local state_file = vim.fn.stdpath("data") .. "/theme_loader_state.json"
    local file = io.open(state_file, "r")
    if not file then return nil end

    local content = file:read("*a")
    file:close()
    local data = vim.fn.json_decode(content)
    if data and data.themes then
        return data.themes
    else
        return nil
    end
end

function M.resetCurrentTheme()
    local state_file = vim.fn.stdpath("data") .. "/theme_loader_state.json"
    local file = io.open(state_file, "r")
    if not file then
        vim.notify("No theme state file found—nothing to reset.", vim.log.levels.INFO)
        return
    end

    local content = file:read("*a")
    file:close()

    local data = vim.fn.json_decode(content)
    if not data or not data.themes then
        vim.notify("No theme data found—nothing to reset.", vim.log.levels.INFO)
        return
    end

    local current_theme = data.selected_theme
    if not current_theme or not data.themes[current_theme] then
        vim.notify("No stored highlights found for '" .. tostring(current_theme) .. "'.", vim.log.levels.INFO)
        return
    end

    -- Remove the theme from data.themes
    data.themes[current_theme] = nil
    data.selected_theme = nil
    data.last_index = nil -- if you no longer need indexes, just clear it

    -- Clear in-memory tracking
    M.title = ""
    M.changed_highlights = {}

    -- Write updated data
    file = io.open(state_file, "w")
    if file then
        file:write(vim.fn.json_encode(data))
        file:close()
        vim.notify("Removed theme '" .. current_theme .. "' from persisted state.", vim.log.levels.INFO)
    else
        vim.notify("Failed to update theme state file.", vim.log.levels.ERROR)
        return
    end

    -- Optionally reset to a default theme (if desired)
    -- if opts.themes[opts.default] and opts.themes[opts.default].func then
    --     opts.themes[opts.default].func()
    --     vim.notify("Reset to default theme: " .. opts.themes[opts.default].name, vim.log.levels.INFO)
    -- end
end

function M.resetThemeByIndex(opts)
    local state_file = vim.fn.stdpath("data") .. "/theme_loader_state.json"
    local file = io.open(state_file, "r")
    if not file then
        vim.notify("No theme state file found—nothing to reset.", vim.log.levels.INFO)
        return
    end

    local content = file:read("*a")
    file:close()

    local data = vim.fn.json_decode(content)
    if not data then
        vim.notify("No data found—nothing to reset.", vim.log.levels.INFO)
        return
    end

    -- 1) Get the last_index from the JSON
    local idx = data.last_index
    if not idx or not opts.themes[idx] or not data.themes then
        vim.notify("No valid last_index or theme found—nothing to reset.", vim.log.levels.WARN)
        return
    end

    -- 2) Derive the theme name from opts.themes
    local theme_name = opts.themes[idx].name
    if not theme_name then
        vim.notify("Could not determine theme name at index "..idx, vim.log.levels.INFO)
        return
    end

    -- 3) Check if data.themes has that theme
    if not data.themes or not data.themes[theme_name] then
        vim.notify("No stored highlights found for theme '"..theme_name.."'.", vim.log.levels.INFO)
        return
    end

    -- 4) Remove the theme from data.themes
    data.themes[theme_name] = nil

    -- 5) Clear selected_theme & last_index if you want a full reset
    data.selected_theme = nil
    data.last_index = nil

    -- 6) Clear in-memory tracking
    M.title = ""
    M.changed_highlights = {}

    -- 7) Write updated data
    file = io.open(state_file, "w")
    if file then
        file:write(vim.fn.json_encode(data))
        file:close()
        vim.notify("Removed theme '" .. theme_name .. "' (index "..idx..") from persisted state.", vim.log.levels.INFO)
    else
        vim.notify("Failed to update theme state file.", vim.log.levels.ERROR)
    end

    -- now run the theme to reset it completely
    if opts.themes[opts.default] and opts.themes[opts.default].func then
        opts.themes[opts.default].func()
        vim.notify("Reset to default theme: " .. opts.themes[opts.default].name, vim.log.levels.INFO)
    end
end

return M
