local config = require("context-yank.config")
local context = require("context-yank.context")
local format = require("context-yank.format")

local M = {}

---Configure the plugin.
---@param opts? ContextYank.Config
function M.setup(opts)
  config.setup(opts)
end

---Yank a formatted context into the configured register and notify.
---@param ctx ContextYank.Context
local function do_yank(ctx)
  local text = format.to_markdown(ctx, { trim_indent = config.options.trim_indent })
  vim.fn.setreg(config.options.register, text)
  if config.options.notify then
    local range = ""
    if ctx.start_line and ctx.end_line then
      range = string.format(" (L%d-L%d)", ctx.start_line, ctx.end_line)
    end
    vim.notify(string.format("context-yank: yanked %s%s", ctx.path, range), vim.log.levels.INFO)
  end
  return text
end

---Yank the whole current buffer.
---@param bufnr? integer
function M.yank_file(bufnr)
  return do_yank(context.from_file(bufnr))
end

---Yank the last visual selection.
---@param bufnr? integer
function M.yank_selection(bufnr)
  return do_yank(context.from_selection(bufnr))
end

---Yank an explicit 1-based line range.
---@param start_line integer
---@param end_line integer
---@param bufnr? integer
function M.yank_range(start_line, end_line, bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  return do_yank(context.from_range(bufnr, start_line, end_line))
end

return M
