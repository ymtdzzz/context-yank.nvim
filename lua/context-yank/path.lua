local M = {}

---Find the Git root directory containing the given file path.
---Uses `vim.fs.find` (no external command required).
---@param filepath string Absolute path of the file (or its directory).
---@return string? root Absolute path of the Git root, or nil when not found.
function M.git_root(filepath)
  if filepath == nil or filepath == "" then
    return nil
  end
  local start = vim.fn.isdirectory(filepath) == 1 and filepath or vim.fs.dirname(filepath)
  local found = vim.fs.find({ ".git" }, { path = start, upward = true })[1]
  if not found then
    return nil
  end
  return vim.fs.dirname(found)
end

---Return `path` relative to `base`, or nil when `path` is not under `base`.
---@param path string Absolute path.
---@param base string Absolute base directory.
---@return string?
local function make_relative(path, base)
  path = vim.fs.normalize(path)
  base = vim.fs.normalize(base)
  if base:sub(-1) ~= "/" then
    base = base .. "/"
  end
  if path:sub(1, #base) == base then
    return path:sub(#base + 1)
  end
  return nil
end

---Resolve a display path for a buffer name according to the given style.
---@param bufname string Buffer name (path). May be relative or absolute.
---@param style "auto"|"relative"|"absolute"
---@return string
function M.resolve(bufname, style)
  if bufname == nil or bufname == "" then
    return "[No Name]"
  end

  local absolute = vim.fn.fnamemodify(bufname, ":p")

  if style == "absolute" then
    return vim.fs.normalize(absolute)
  end

  if style == "relative" then
    return vim.fn.fnamemodify(bufname, ":.")
  end

  -- "auto": prefer Git root relative, fall back to cwd relative.
  local root = M.git_root(absolute)
  if root then
    local rel = make_relative(absolute, root)
    if rel then
      return rel
    end
  end
  return vim.fn.fnamemodify(bufname, ":.")
end

return M
