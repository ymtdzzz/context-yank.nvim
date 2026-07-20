local context = require("context-yank.context")

local function termcodes(keys)
  return vim.api.nvim_replace_termcodes(keys, true, false, true)
end

describe("from_selection (bug reproduction)", function()
  local bufnr

  before_each(function()
    bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
      "line 1",
      "line 2",
      "line 3",
      "line 4",
      "line 5",
      "line 6",
    })
    vim.bo[bufnr].filetype = "lua"
    vim.api.nvim_set_current_buf(bufnr)
  end)

  after_each(function()
    -- Make sure we never leave the harness stuck in Visual mode.
    vim.api.nvim_feedkeys(termcodes("<Esc>"), "x", false)
    if vim.api.nvim_buf_is_valid(bufnr) then
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end
  end)

  it("reflects the current visual selection, not the stale '</'> marks", function()
    vim.api.nvim_feedkeys(termcodes("ggVj<Esc>"), "x", false)

    local captured
    vim.keymap.set("x", "<F2>", function()
      captured = context.from_selection(bufnr)
    end, { buffer = bufnr })

    vim.api.nvim_win_set_cursor(0, { 4, 0 })
    vim.api.nvim_feedkeys(termcodes("Vj<F2><Esc>"), "x", false)

    assert.is_not_nil(captured)
    assert.are.equal(4, captured.start_line)
    assert.are.equal(5, captured.end_line)
    assert.are.same({ "line 4", "line 5" }, captured.lines)
  end)

  it("does not fabricate an (L0) empty range when no selection ever existed", function()
    local fresh = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(fresh, 0, -1, false, { "a", "b", "c" })
    vim.api.nvim_set_current_buf(fresh)

    local ctx = context.from_selection(fresh)

    assert.is_true(ctx.start_line >= 1, "start_line should be a real 1-based line, got " .. tostring(ctx.start_line))
    assert.is_true(ctx.end_line >= 1, "end_line should be a real 1-based line, got " .. tostring(ctx.end_line))

    vim.api.nvim_buf_delete(fresh, { force = true })
  end)
end)
