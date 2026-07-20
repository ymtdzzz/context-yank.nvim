local M = {}

---@class ContextYank.Config
---@field register string Register to yank into (default: system clipboard "+").
---@field path_style "auto"|"relative"|"absolute" How to render the file path.
---@field notify boolean Whether to notify on successful yank.
---@field trim_indent boolean Strip common leading indentation from a selection.

---@type ContextYank.Config
M.defaults = {
  register = "+",
  path_style = "auto",
  notify = true,
  trim_indent = false,
}

---@type ContextYank.Config
M.options = vim.deepcopy(M.defaults)

---Merge user options into the defaults.
---@param opts? table
---@return ContextYank.Config
function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", vim.deepcopy(M.defaults), opts or {})
  return M.options
end

return M
