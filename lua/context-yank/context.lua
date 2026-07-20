local config = require("context-yank.config")
local path = require("context-yank.path")

local M = {}

---@class ContextYank.Context
---@field path string Display path of the buffer.
---@field lang string Filetype used as the code-fence language ("" when unknown).
---@field start_line integer? 1-based start line (nil for a whole file).
---@field end_line integer? 1-based end line (nil for a whole file).
---@field lines string[] Collected buffer lines.

---Resolve the display path for a buffer.
---@param bufnr integer
---@return string
local function resolve_path(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr)
  return path.resolve(name, config.options.path_style)
end

---Build a context for the whole buffer.
---@param bufnr? integer Defaults to the current buffer.
---@return ContextYank.Context
function M.from_file(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  return {
    path = resolve_path(bufnr),
    lang = vim.bo[bufnr].filetype or "",
    start_line = nil,
    end_line = nil,
    lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false),
  }
end

---Build a context from the current or last visual selection.
---
---While Visual mode is still active the `'<`/`'>` marks are stale (they only
---update when the selection is left), so the live `v`/`.` positions are used
---instead; outside Visual mode we fall back to the marks. When neither is set
---(no selection has ever been made) we fall back to the cursor line so we never
---emit a bogus line 0.
---@param bufnr? integer Defaults to the current buffer.
---@return ContextYank.Context
function M.from_selection(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  local mode = vim.fn.mode()
  local start_line, end_line
  if mode == "v" or mode == "V" or mode == "\22" then
    start_line = vim.fn.getpos("v")[2]
    end_line = vim.fn.getpos(".")[2]
  else
    start_line = vim.fn.getpos("'<")[2]
    end_line = vim.fn.getpos("'>")[2]
  end

  if start_line == 0 or end_line == 0 then
    local cursor = vim.api.nvim_win_get_cursor(0)[1]
    start_line, end_line = cursor, cursor
  end

  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end

  return {
    path = resolve_path(bufnr),
    lang = vim.bo[bufnr].filetype or "",
    start_line = start_line,
    end_line = end_line,
    lines = vim.api.nvim_buf_get_lines(bufnr, start_line - 1, end_line, false),
  }
end

---Build a context from an explicit 1-based line range.
---@param bufnr integer
---@param start_line integer 1-based inclusive.
---@param end_line integer 1-based inclusive.
---@return ContextYank.Context
function M.from_range(bufnr, start_line, end_line)
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end
  return {
    path = resolve_path(bufnr),
    lang = vim.bo[bufnr].filetype or "",
    start_line = start_line,
    end_line = end_line,
    lines = vim.api.nvim_buf_get_lines(bufnr, start_line - 1, end_line, false),
  }
end

return M
