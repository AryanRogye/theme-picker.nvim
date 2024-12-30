local M = {}


local function save_theme_state(index)
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

local function load_theme_state()
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

local function Lt(index)
    local theme = M.opts.themes[index]
    if theme then
        theme.func()
        save_theme_state(index) -- Save the theme index
    else
        vim.notify("Theme not found at index: " .. index, vim.log.levels.WARN)
    end
end

-- Accepts themes which looks like
--- @field default int default index to start at     
--- @field themes  table[] 
---   - `name` (string): The name of the theme.
---   - `func` (function): Function to apply the theme.
--- @Example ↓
--- themes = {
---             { name = "Theme Name" , func = function   <- Make sure no() around it },
---          }
--- TODO Check if colorscheme([]) works or not
---  @field Keys table[] 
---   - `func` (string): Name of the function to call (e.g., "loadThemeByIndex").
---   - `key` (string): Keybinding (e.g., "<leader>t1").
---  @Example ↓
---
---  keys = {
---             { func = "loadThemeByIndex || ltbi" , mode ="n / v / i" ,keys = "<leader> or <C-> whatever this isnt required" },
---         }
local default_opts = {
    default = 1,
    themes = {},
    keys={},
}

M.setup = function(opts)
    M.opts = vim.tbl_deep_extend("force", default_opts, opts or {})

    if #M.opts.themes == 0 then
        print("No themes provided! Please pass themes in setup().")
        return
    end

    local saved_index = load_theme_state()
    if saved_index and saved_index >= 1 and saved_index <= #M.opts.themes then
        M.opts.default = saved_index
    elseif M.opts.default < 1 or M.opts.default > #M.opts.themes then
        print("Invalid default index! Falling back to index 1.")
        M.opts.default = 1
    end

    -- Set up keybindings
    for _, keymap in ipairs(M.opts.keys) do
        local func_name = keymap.func
        local key = keymap.keys
        local mode = keymap.mode or "n"
        if func_name == "ltbi" or func_name == "loadThemeByIndex" then
            vim.api.nvim_set_keymap(
                mode,
                key,
                ":lua require('theme-picker').load_theme_by_index()<CR>",
                { noremap = true, silent = true }
            )
            vim.notify("Keybinding set for " .. func_name) -- Debug
        elseif func_name == "ltbui" or func_name == "loadThemeByUI" then
            vim.api.nvim_set_keymap(
                mode,
                key,
                ":lua require('theme-picker').load_theme_by_ui()<CR>",
                { noremap = true, silent = true }
            )
            vim.notify("Keybinding set for " .. func_name) -- Debug
        else
            print("Unknown function: " .. func_name)
        end
    end
    Lt(M.opts.default)
end

M.load_theme_by_ui = function()
    local ok, ui = pcall(require, "ui")
    if not ok then
        vim.notify("UI module not found!", vim.log.levels.ERROR)
        return
    end
    ui.init()
    vim.notify("Loading By UI!") -- Debugging output
end

-- Wrapper for Lt that prompts for input
M.load_theme_by_index = function()
    local str = vim.fn.input("> ")
    local strI = tonumber(str)
    if strI then
        Lt(strI)
    else
        vim.notify("Invalid input! Please enter a number.", vim.log.levels.WARN)
    end
end

return M
