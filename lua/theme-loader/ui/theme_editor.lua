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


local storage = require("theme-loader.storage")

-- Safely apply highlight changes without throwing errors
local function safe_apply_highlight(highlight_group, highlight_property, new_value)
    local current_hl = vim.api.nvim_get_hl(0, { name = highlight_group })

    -- Format the value appropriately for the highlight group
    if highlight_property == "fg" or highlight_property == "bg" then
        -- For color values, try to format properly
        -- Remove # if it exists, then add it back to ensure consistent format
        new_value = new_value:gsub("^#", "")

        -- Only apply if the value looks like a valid hex color
        if new_value:match("^%x+$") and (#new_value == 6 or #new_value == 3) then
            current_hl[highlight_property] = "#" .. new_value
            vim.api.nvim_set_hl(0, highlight_group, current_hl)

            -- Ensure storage tracks per highlight group
            storage.title = M.title
            storage.changed_highlights[highlight_group] = storage.changed_highlights[highlight_group] or {}
            storage.changed_highlights[highlight_group][highlight_property] = "#" .. new_value

            return true, "#" .. new_value
        end
    elseif highlight_property == "ctermfg" or highlight_property == "ctermbg" or highlight_property == "blend" then
        -- For numeric values, convert to number if possible
        local num_value = tonumber(new_value)
        if num_value then
            current_hl[highlight_property] = num_value
            vim.api.nvim_set_hl(0, highlight_group, current_hl)

            -- Store numeric highlight changes per group
            storage.title = M.title
            storage.changed_highlights[highlight_group] = storage.changed_highlights[highlight_group] or {}
            storage.changed_highlights[highlight_group][highlight_property] = num_value

            return true, tostring(num_value)
        end
    end
    return false, new_value
end

function M.handle_textChange(edit_buf, highlight_values, highlight_group, highlight_property)
    vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
        buffer = edit_buf,
        callback = function()
            -- Get the New Value
            local new_value = vim.api.nvim_buf_get_lines(edit_buf, 0, -1, false)[1]
            -- Attempt to apply the highlight
            local success, formatted_value = safe_apply_highlight(highlight_group, highlight_property, new_value)
            if success then
                --update the stored highlight values
                highlight_values[highlight_group][highlight_property] = formatted_value
                vim.cmd("redraw")
            end
        end
    })
end

function M.handle_leavingBuffer(edit_buf, highlight_values,highlight_group, highlight_property, opts)
    vim.api.nvim_create_autocmd("BufLeave", {
        buffer = edit_buf,
        callback = function()
            -- Getting the value from the buffer
            local new_value = vim.api.nvim_buf_get_lines(edit_buf, 0, -1, false)[1]

            local success, formatted_value = safe_apply_highlight(highlight_group, highlight_property, new_value)

            if success then
                -- Update the value in memory
                highlight_values[highlight_group][highlight_property] = formatted_value

                -- Update the displayed text
                for i, line in ipairs(M.lines) do
                    if line:match("%[.-%]%s+" .. highlight_property) then
                        M.lines[i] = opts.config.opening .. " " .. highlight_property .. ": " .. formatted_value .. opts.config.closing
                        vim.api.nvim_buf_set_lines(M.buf, i - 1, i, false, { M.lines[i] })
                        break
                    end
                end

                vim.cmd("redraw")
                print("Updated " .. highlight_group .. " → " .. highlight_property .. " to " .. formatted_value)
            else
                print("No change applied - value was not in the correct format")
            end

            -- Close buffer
            vim.api.nvim_buf_delete(edit_buf, { force = true })

            -- Wanna ask to persist changes or not 
        end
    })
end

function M.setup_keybinds(highlight_values, opts)
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
            local row, col = unpack(vim.api.nvim_win_get_cursor(M.win))
            local selected = row

            -- Get the text of the selected line
            local selected_text = M.lines[selected]
            print("Selected text:", selected_text)

            -- Check if it's a property line (has brackets)
            if selected_text:match("%[.-%]") then
                -- Extract property name
                local highlight_property = selected_text:match("%[.-%]%s+(.*)")
                print("Property:", highlight_property)

                -- Find parent group
                local highlight_group = nil
                for i = selected - 1, 1, -1 do
                    if not M.lines[i]:match("%[.-%]") then
                        highlight_group = M.lines[i]
                        break
                    end
                end
                print("Group:", highlight_group)

                -- Print the value if it exists
                if highlight_group and highlight_property and
                    highlight_values[highlight_group] and
                    highlight_values[highlight_group][highlight_property] then
                    print("Value:", highlight_values[highlight_group][highlight_property])

                    -- Continue with the editing logic (open split, etc.)
                    vim.cmd("vsplit")
                    local edit_buf = vim.api.nvim_create_buf(false, true)
                    vim.api.nvim_win_set_buf(0, edit_buf)

                    local current_value = highlight_values[highlight_group][highlight_property]

                    -- Make it modifiable and insert current value
                    vim.api.nvim_buf_set_option(edit_buf, "modifiable", true)
                    vim.api.nvim_buf_set_lines(edit_buf, 0, -1, false, { current_value })

                    -- Handle text changes
                    M.handle_textChange(edit_buf, highlight_values, highlight_group, highlight_property)
                    -- Save changes on exit
                    M.handle_leavingBuffer(edit_buf, highlight_values, highlight_group, highlight_property, opts)
                else
                    print("No value found for", highlight_group, highlight_property)
                    -- Debug what we have in the values table
                    print("Available values:", vim.inspect(highlight_values))
                end
            else
                print("Selected a group:", selected_text)
            end
        end
    })
end




M.highlight_groups = { "Normal", "CursorLine", "Comment" }

-- Get A list of all the highlight groups and their values
-- Function also formatted highlight values into a table for displaying
-- Return the formatted highlight values
-- Format will be
-- { 
--      Normal = {
--          fg = "#ffffff",
--          bg = "#000000",
--      }
--      CursorLine = {
--         fg = "#ffffff",
--      }
--      .....etc..
--
-- }
function M.displayHighlightInfo(opts)
    local highlight_used_values = {}
    -- unselected opening that the user selected in the configs
    local unselected = opts.config.opening .. " " .. opts.config.closing
    -- Loop through each highlight group
    for _, group in ipairs(M.highlight_groups) do
        local highlight_info = vim.api.nvim_get_hl(0, { name = group, link = false })
        -- Only store if the highlight group exists
        if next(highlight_info) then
            -- Create a new table for the group
            highlight_used_values[group] = {}
            -- Display group name as a standalone section header
            table.insert(M.lines, group)
            for key, color in pairs(highlight_info) do
                -- If the key is a displayable property, store it
                if display_highlight_properties[key] then
                    highlight_used_values[group][key] = to_hex(tostring(color))
                    -- Checkbox selection style
                    table.insert(M.lines, unselected .. " " .. key)
                end
            end
        end
    end
    return highlight_used_values
end

function M.display_title(opts)
    -- add the title
    if opts.themes then
        local theme_idx = require("theme-loader.ui.theme_selector").getCurrentThemeIndex()
        if opts.themes[theme_idx] then
            -- adding the name from the theme = { name = .... }
            M.title = opts.themes[theme_idx].name
            table.insert(M.lines,"Highlight Information For " .. opts.themes[theme_idx].name)
        end
    end
end


function M.setup(opts)

    M.buf = vim.api.nvim_create_buf(false, true)
    -- open the buffer inside a small horizontal split
    vim.cmd("split")
    M.win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(M.win, M.buf)

    M.lines = {}
    M.title = ""

    -- Display the title and the highlight information
    M.display_title(opts)
    local highlight_values = M.displayHighlightInfo(opts)

    -- Setup the keybinds
    M.setup_keybinds(highlight_values, opts)
    -- Set lines inside buffer
    vim.api.nvim_buf_set_lines(M.buf, 0, -1, false, M.lines)
    -- Set cursor to line 2
    vim.api.nvim_win_set_cursor(M.win, { 3, #opts.config.opening }) -- { row, column }
end

return M
