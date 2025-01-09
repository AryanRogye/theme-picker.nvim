local M = {}
local Popup = require("nui.popup")
local event = require("nui.utils.autocmd").event

function M.setup(themes)
    -- Create the popup
    local popup = Popup({
        position = "50%", -- Center the popup
        size = {
            width = 40,
            height = #themes + 2, -- Dynamic height based on themes
        },
        border = {
            style = "rounded",
            text = {
                top = " Theme Picker ",
                top_align = "center",
            },
        },
        win_options = {
            winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
        },
    })

    -- Mount the popup
    popup:mount()

    -- Add key bindings for navigation
    local selected_index = 1
    local function render_content()
        popup:unmount()
        popup:mount()
        popup.buf:lines_clear()
        -- for i, theme in ipairs(themes) do
        --     lines()
        --     popup:theme_picker()
        -- end
    end

end

return M
