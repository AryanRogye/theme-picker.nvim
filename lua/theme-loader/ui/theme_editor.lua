local M = {}

local display_highlight_properties = {
    fg = true,
    bg = true,
    ctermfg = true,
    ctermbg = true,
    blend = true
}
local display_highlight_properties_str = {
    fg = "Foreground",
    bg = "Background",
    ctermfg = "CTerm Foreground",
    ctermbg = "CTerm Background",
    blend = "Blend"
}

local function to_hex(dec)
    return string.format("#%06x", dec)
end


-- Safely apply highlight changes without throwing errors
local function safe_apply_highlight(highlight_group, new_value)
    local current_hl = vim.api.nvim_get_hl(0, { name = "Normal" })

    -- Format the value appropriately for the highlight group
    if highlight_group == "fg" or highlight_group == "bg" then
        -- For color values, try to format properly
        -- Remove # if it exists, then add it back to ensure consistent format
        new_value = new_value:gsub("^#", "")

        -- Only apply if the value looks like a valid hex color
        if new_value:match("^%x+$") and (#new_value == 6 or #new_value == 3) then
            current_hl[highlight_group] = "#" .. new_value
            vim.api.nvim_set_hl(0, "Normal", current_hl)
            return true, "#" .. new_value
        end
    elseif highlight_group == "ctermfg" or highlight_group == "ctermbg" or highlight_group == "blend" then
        -- For numeric values, convert to number if possible
        local num_value = tonumber(new_value)
        if num_value then
            current_hl[highlight_group] = num_value
            vim.api.nvim_set_hl(0, "Normal", current_hl)
            return true, tostring(num_value)
        end
    end
    return false, new_value
end

function M.handle_textChange(edit_buf, highlight_values, selected, highlight_group)
    vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
        buffer = edit_buf,
        callback = function()
            -- Get the New Value
            local new_value = vim.api.nvim_buf_get_lines(edit_buf, 0, -1, false)[1]
            -- Attempt to apply the highlight
            local success, formatted_value = safe_apply_highlight(highlight_group, new_value)
            if success then
                highlight_values[selected].value = formatted_value
                vim.cmd("redraw")
            end
        end
    })
end

function M.handle_leavingBuffer(edit_buf, highlight_values, selected, highlight_group)
    vim.api.nvim_create_autocmd("BufLeave", {
        buffer = edit_buf,
        callback = function()
            -- Getting the value from the buffer
            local new_value = vim.api.nvim_buf_get_lines(edit_buf, 0, -1, false)[1]

            local success, formatted_value = safe_apply_highlight(highlight_group, new_value)

            if success then
                -- Update the value in memory
                highlight_values[selected].value = formatted_value

                -- Update the displayed text
                if M.lines and M.lines[selected + 1] then
                    local prefix = M.lines[selected + 1]:match("^([^:]+): ")
                    if prefix then
                        M.lines[selected + 1] = prefix .. ": " .. formatted_value
                        vim.api.nvim_buf_set_lines(M.buf, selected, selected + 1, false, { M.lines[selected + 1] })
                    end
                end

                vim.cmd("redraw")
                print("Updated " .. display_highlight_properties_str[highlight_group] .. " to " .. formatted_value)
            else
                -- Just close without showing an error
                print("No change applied - value was not in the correct format")
            end

            -- Close buffer
            vim.api.nvim_buf_delete(edit_buf, { force = true })

            -- Wanna ask to persist changes or not 
        end
    })
end

function M.setup_keybinds(highlight_values)
    -- Keybind to quit out of the buffer
    vim.api.nvim_buf_set_keymap(M.buf, "n", "q", "", {
        noremap = true,
        silent = true,
        callback = function()
            vim.api.nvim_set_option_value("modifiable", true, {})
            vim.api.nvim_buf_delete(M.buf, { force = true })
        end
    })

    -- Keybind to Edit the highlight value
    vim.api.nvim_buf_set_keymap(M.buf, "n", "<CR>", "", {
        noremap = true,
        silent = true,
        callback = function()

            -- wanna see which row and column we are on
            -- the selected will be 1 less than the row in the buffer/#highlight_values
            local row, col = unpack(vim.api.nvim_win_get_cursor(M.win))
            local selected = row - 1

            -- make sure that a value is able to be selected
            if not highlight_values[selected] then
                print("No value selected")
                return
            end


            local highlight_group = highlight_values[selected].group
            local current_value = highlight_values[selected].value

            -- wanna open up the buffer in a split state
            vim.cmd("vsplit")
            local edit_buf = vim.api.nvim_create_buf(false, true) -- No file, scratch buffer
            vim.api.nvim_win_set_buf(0, edit_buf)

            -- Make it modifiable and insert current value
            vim.api.nvim_buf_set_option(edit_buf, "modifiable", true)
            vim.api.nvim_buf_set_lines(edit_buf, 0, -1, false, { current_value })

            -- Handle text changes
            M.handle_textChange(edit_buf, highlight_values, selected, highlight_group)
            -- Save changes on exit
            M.handle_leavingBuffer(edit_buf, highlight_values, selected, highlight_group)
        end
    })
end

function M.displayHighlightInfo(opts)
    local highlight_info = vim.api.nvim_get_hl(0, { name = "Normal" })
    -- array to store all the values that were actually used
    local highlight_used_values = {}
    -- local selected = opts.config.opening .. opts.config.selection .. opts.config.closing
    local unselected = opts.config.opening .. " " .. opts.config.closing

    -- Add the highlight information
    for key, color in pairs(highlight_info) do
        -- if the color has the property of display_highlight_properties then only display it
        if display_highlight_properties[key] then
            local hex_value = to_hex(tostring(color))
            -- add the color/hex to the array(highlight_used_values) to return
            table.insert(highlight_used_values, { group = key, value = hex_value })
            table.insert(M.lines, unselected .. display_highlight_properties_str[key] .. ": " .. hex_value)
        end
    end

    return highlight_used_values
end

function M.setup(opts)

    M.buf = vim.api.nvim_create_buf(false, true)
    -- open the buffer inside a small horizontal split
    vim.cmd("split")
    M.win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(M.win, M.buf)

    M.lines = {}

    -- add the title
    if opts.themes then
        local theme_idx = require("theme-loader.ui.theme_selector").getCurrentThemeIndex()
        if opts.themes[theme_idx] then
            -- adding the name from the theme = { name = .... }
            table.insert(M.lines,"Highlight Information For " .. opts.themes[theme_idx].name)
        end
    end

    -- Display the highlight information
    local highlight_values = M.displayHighlightInfo(opts)

    -- Setup the keybinds
    M.setup_keybinds(highlight_values)

    -- Set lines inside buffer
    vim.api.nvim_buf_set_lines(M.buf, 0, -1, false, M.lines)
    -- Set cursor to line 2
    local colLoc = #opts.config.opening
    vim.api.nvim_win_set_cursor(M.win, { 2, colLoc }) -- { row, column }

end

return M
