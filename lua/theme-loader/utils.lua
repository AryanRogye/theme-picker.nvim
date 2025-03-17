local M = {}

-- Normal → Default text style (main text color).
-- NormalNC → Same as Normal, but for inactive windows.
-- Cursor → The cursor color.
-- CursorLine → The highlight for the current line.
-- CursorLineNr → The number color for the current line.
-- LineNr → Line numbers in the gutter.
-- SignColumn → The column where signs (e.g., LSP, Git) appear.
-- VertSplit → Vertical window separators.
-- WinSeparator → Newer alternative to VertSplit.

-- Comment → Comments (--, //, #).
-- Keyword → Keywords (if, else, return).
-- Function → Function names.
-- Identifier → Variable names.
-- Statement → Statements (break, continue).
-- Constant → Constants (e.g., true, false, numbers).
-- String → String literals ("hello").
-- Character → Single characters ('a').
-- Type → Data types (int, float).
-- Special → Special symbols (*, &, #).
-- Operator → Operators (+, -, =, ==).
-- PreProc → Preprocessor statements (#define, import).
-- Underlined → Underlined text (often for URLs).

-- Visual → Selection highlight (when selecting text).
-- Search → Search match highlighting.
-- IncSearch → Incremental search highlight.
-- Pmenu → Popup menu background (autocomplete suggestions).
-- PmenuSel → Selected item in the popup menu.
-- StatusLine → The status line (active window).
-- StatusLineNC → The status line (inactive windows).
-- TabLine → The tab bar.
-- TabLineSel → The active tab.
-- TabLineFill → The background of tabs.


-- MatchParen → Matching parentheses/brackets.
-- Bracket → Bracket colors.
-- Delimiter → Commas, semicolons, and other delimiters.

-- DiagnosticError → Error messages.
-- DiagnosticWarn → Warnings.
-- DiagnosticInfo → Informational messages.
-- DiagnosticHint → Hints and suggestions.
-- LspReferenceText → Highlighting for references (LSP).
-- LspReferenceRead → Highlight for read occurrences.
-- LspReferenceWrite → Highlight for write occurrences.

-- @function → Functions and methods.
-- @keyword → Keywords.
-- @variable → Variables.
-- @string → Strings.
-- @type → Types and classes.
-- @parameter → Function parameters.
-- @comment → Comments.

-- EditorForeground → Text color (sometimes just Normal).
-- EditorBackground → Background color.

function M.get_highlight_groups()
    local highlight_groups = {}
    for _, group in ipairs(vim.fn.getcompletion("", "highlight")) do
        local hl = vim.api.nvim_get_hl(0, { name = group })
        if hl and next(hl) then -- Ensure the highlight group has values
            highlight_groups[group] = hl
        end
    end
    return highlight_groups
end

function M.get_highlight_str_info(info)
    local highlights = M.get_highlight_groups()
    local values = highlights[info]

    if values then
        -- Convert table to a readable list of strings
        local result = { info .. ":" }
        for k, v in pairs(values) do
            table.insert(result, "  " .. k .. " = " .. tostring(v))
        end
        return result  -- Returns a table of strings instead of one long string
    else
        return { "No Information for " .. info .. " found" }  -- Still returns a table
    end
end

return M
