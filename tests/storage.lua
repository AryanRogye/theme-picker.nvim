local storage = require("theme-loader.storage")

-- Save a test theme and reload to check if it's stored correctly
storage.title = "TestTheme"
storage.changed_highlights = {
    Normal = { bg = "#1d2021", fg = "#ebdbb2" }
}

storage.saveState()
storage.loadState()

if storage.changed_highlights["Normal"] and storage.changed_highlights["Normal"].bg == "#1d2021" then
    print("Storage works ✅")
else
    print("Storage failed ❌")
end


-- Try removing the saved theme
local opts = {
    themes = {
        { name = "TestTheme" }
    },
    default = 1
}

storage.resetThemeByIndex(opts) -- Remove "TestTheme"

-- Save the theme
storage.title = "TestTheme"               -- Means selected_theme = "TestTheme"
storage.changed_highlights = { ... }
storage.saveState()                       -- Writes selected_theme in the JSON

-- Now remove by name
storage.resetCurrentTheme()               -- Removes "TestTheme"
storage.loadState()

local themes_data = storage.getAllThemesData()
if not themes_data or not themes_data["TestTheme"] then
    print("Remove theme works ✅")
else
    print("Remove theme failed ❌")
end


-- Try resetting a theme that doesn’t exist (should fail safely)
local opts_fake = {
    themes = {
        { name = "FakeTheme" }
    },
    default = 1
}

storage.resetThemeByIndex(opts_fake) -- Should not crash
print("Fake theme reset test completed ✅")
