local core = require("theme-loader.core")
local commands = require("theme-loader.commands")
local M = {}

-- Accepts themes which looks like
-- @field default int default index to start at     
-- @field themes  table[] 
---   - `name` (string): The name of the theme.
---   - `func` (function): Function to apply the theme.
-- @Example ↓
--- themes = {
---             { name = "Theme Name" , func = function   <- Make sure no() around it },
---          }
-- TODO Check if colorscheme([]) works or not
-- @field Keys table[] 
---  - `func` (string): Name of the function to call (e.g., "loadThemeByIndex").
---   - `key` (string): Keybinding (e.g., "<leader>t1").
--  @Example ↓
---
---  keys = {
---             { func = "loadThemeByIndex || ltbi" , mode ="n / v / i" ,keys = "<leader> or <C-> whatever this isnt required" },
---         }
local defaults = {
    default = 1,
    themes = {},
    keys={},
    config={
        ui_col_spacing = 20,
        opening = "[",
        closing = "]",
        selection = "X",
        preview = true
    },
}

function M.UI()
    commands.load_theme_by_ui()
end
function M.INDEX()
    commands.load_theme_by_index()
end
function M.COLOR_PICKER()
    commands.load_color_picker()
end


-- This is the names which map to a index
-- The indexes are used in the functions which match to a function
local names = {
    ["ltbui"] = 1,
    ["loadThemeByUI"] = 1,
    ["ltbi"] = 2,
    ["loadThemeByIndex"] = 2,
    ["lcp"] = 3,
    ["loadColorPicker"] = 3
}

local functions = {
    [1] = function() require("theme-loader.configs").UI() end,
    [2] = function() require('theme-loader.configs').INDEX() end,
    [3] = function() require("theme-loader.configs").COLOR_PICKER() end,
}


local function handleFuncName(mode,key,func_name)
    local index = names[func_name]
    if not index then
        vim.notify("Index Not Found", vim.log.levels.ERROR)
        return
    end
    local func = functions[index]
    if not func then
        vim.notify("Func Not Found", vim.log.levels.ERROR)
        return
    end

    vim.keymap.set(
        mode,
        key,
        func,
        { noremap = true, silent = true }
    )
end


function M.handleThemes(opts)
    if #opts.themes == 0 then
        return false, "No themes provided! Please pass themes in setup()."
    end
    return true
end

function M.handleKeyBindings(opts)
    -- Loop Through The Keys
    for _, keymap in ipairs(opts.keys) do
        local func_name = keymap.func
        local key = keymap.keys
        local mode = keymap.mode or "n"
        -- Verify These Exist
        if not func_name then
            return false, "No Function Name Provided"
        end
        if not key then
            return false, "No Keys Provided"
        end
        handleFuncName(mode, key, func_name)
    end
    return true
end

function M.handleCurrentThemeState(opts)
    local saved_index = core.load_theme_state()
    if saved_index and saved_index >= 1 and saved_index <= #opts.themes then
        opts.default = saved_index
    elseif opts.default < 1 or opts.default > #opts.themes then
        print("Invalid default index! Falling back to index 1.")
        opts.default = 1
    end
end

function M.setup(opts)
    M.opts = vim.tbl_deep_extend("force", defaults, opts or {})
    core.setup(M.opts)
    commands.setup(M.opts)

    -- Handle Themes
    local isValid, err = M.handleThemes(M.opts)
    if not isValid then
        if err then
            vim.notify(err, vim.log.levels.ERROR)
        else
            vim.notify("There Was An Error With The Themes", vim.log.levels.ERROR)
        end
        return
    end
    -- Handle Current Theme State By Loading Last Theme
    M.handleCurrentThemeState(M.opts)
    -- Setup Key Bindings
    isValid, err = M.handleKeyBindings(M.opts)
    if not isValid then
        if err then
            vim.notify(err, vim.log.levels.ERROR)
        end
        vim.notify("There Was An Error With The Keybindings", vim.log.levels.ERROR)
    end
    core.loadTheme(M.opts.default)
end


return M
