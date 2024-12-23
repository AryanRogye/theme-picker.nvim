# theme-picker.nvim

**theme-picker.nvim** is a Neovim plugin to make switching themes effortless.

## Features
- Switch between multiple themes easily.
- Bind keys to select and load themes dynamically.

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim):
```lua
{
    'AryanRogye/theme-picker.nvim',
    config = function()
    end
}
```
## Getting Started

### Suggestions

#### Dependencies
This plugin works with any Neovim theme. The following examples use:
- [GruvBox](https://github.com/morhetz/gruvbox)
- [Dark Flat](https://github.com/sekke276/dark_flat.nvim)


Ensure these plugins are installed for the configurations to work as intended. You can install them using your favorite plugin manager, such as [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
-- Install GruvBox
{
    'morhetz/gruvbox',
    lazy = false
}
```
```lua
-- Install Dark Flat
{
    "sekke276/dark_flat.nvim",
    lazy = false
},
```


 - Having a centralized location for themes - For Example:
 ```lua 
-- File: lua/my-themes.lua
local M = {}

-- Example Themes

M.load_gruvbox = function()
    -- Set GruvBox-specific configurations
        vim.opt.termguicolors = true
    vim.g.gruvbox_contrast_light = 'hard'
    vim.cmd([[colorscheme gruvbox]])
    vim.cmd([[
        highlight Normal guibg=NONE ctermbg=NONE
    ]])
end

M.load_dark_flat = function()
    -- Set dark_flat-specific configurations
    vim.cmd.colorscheme "dark_flat"
end

return M
 ```




### Using The Plugin
```lua
    {
        'AryanRogye/theme-picker.nvim',
        config = function()
--          This is where you load in your themes
--          In the suggestions above it shows how to set something similar
--          There is also an example if you decided not to setup a lua file to load themes
            local theme = require("my-themes")
            require("theme-loader").setup({
--              if this is not set no default theme will need keys or command
                default = 2,    -- default index if no keys set
                themes = {
--                  Load Theme in format name = "" func = func <- Make sure no ()
                    { name = "GruvBox", func = theme.load_gruvbox },
                    { name = "Dark Flat", func = theme.load_dark_flat },
--                  This is if You Directly Want To Load Theme Through Here
--                  { name = "GruvBox", func = function()
--                             Set GruvBox-specific configurations
--                             vim.opt.termguicolors = true
--                             vim.g.gruvbox_contrast_light = 'hard'
--                             vim.cmd([[colorscheme gruvbox]])
--                             vim.cmd([[
--                                highlight Normal guibg=NONE ctermbg=NONE
--                             ]])
--                   end },
                },
                keys = {
                    -- Format is This The only func is ltbi or loadThemeByIndex
                    {func = "ltbi", mode = "n" , keys = "<leader>ll"},
                }
            })
        end,
    },

```

## Acknowledgments
- [GruvBox](https://github.com/morhetz/gruvbox) for its vibrant color scheme.
- [Dark Flat](https://github.com/sekke276/dark_flat.nvim) for its clean, minimalist look.
- [lazy.nvim](https://github.com/folke/lazy.nvim) for managing Neovim plugins.
