local M = {}

---Build the header line, e.g. `` `path` (L10-L20) ``.
---@param ctx ContextYank.Context
---@return string
local function build_header(ctx)
  local header = "`" .. ctx.path .. "`"
  if ctx.start_line and ctx.end_line then
    if ctx.start_line == ctx.end_line then
      header = header .. string.format(" (L%d)", ctx.start_line)
    else
      header = header .. string.format(" (L%d-L%d)", ctx.start_line, ctx.end_line)
    end
  end
  return header
end

---Return a fence string long enough to safely wrap the given lines.
---Markdown requires the fence to be longer than any backtick run inside the
---content, with a minimum of three backticks.
---@param lines string[]
---@return string
local function build_fence(lines)
  local longest = 0
  for _, line in ipairs(lines) do
    for run in line:gmatch("`+") do
      if #run > longest then
        longest = #run
      end
    end
  end
  return string.rep("`", math.max(3, longest + 1))
end

---Remove the common leading whitespace shared by all non-blank lines.
---@param lines string[]
---@return string[]
local function trim_common_indent(lines)
  local min_indent = nil
  for _, line in ipairs(lines) do
    if line:match("%S") then
      local indent = #(line:match("^%s*"))
      if min_indent == nil or indent < min_indent then
        min_indent = indent
      end
    end
  end
  if not min_indent or min_indent == 0 then
    return lines
  end
  local result = {}
  for i, line in ipairs(lines) do
    result[i] = line:sub(min_indent + 1)
  end
  return result
end

---Render a context as a Markdown code block string.
---@param ctx ContextYank.Context
---@param opts? { trim_indent?: boolean }
---@return string
function M.to_markdown(ctx, opts)
  opts = opts or {}
  local lines = ctx.lines
  if opts.trim_indent then
    lines = trim_common_indent(lines)
  end

  local fence = build_fence(lines)
  local out = { build_header(ctx), "", fence .. (ctx.lang ~= "" and ctx.lang or "") }
  vim.list_extend(out, lines)
  table.insert(out, fence)

  return table.concat(out, "\n")
end

return M
