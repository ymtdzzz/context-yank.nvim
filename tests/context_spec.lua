local context = require("context-yank.context")

describe("context collection", function()
  local bufnr

  before_each(function()
    bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
      "line 1",
      "line 2",
      "line 3",
      "line 4",
    })
    vim.bo[bufnr].filetype = "lua"
  end)

  after_each(function()
    if vim.api.nvim_buf_is_valid(bufnr) then
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end
  end)

  it("collects the whole buffer with no line range", function()
    local ctx = context.from_file(bufnr)
    assert.are.equal("lua", ctx.lang)
    assert.is_nil(ctx.start_line)
    assert.is_nil(ctx.end_line)
    assert.are.same({ "line 1", "line 2", "line 3", "line 4" }, ctx.lines)
  end)

  it("collects an explicit line range", function()
    local ctx = context.from_range(bufnr, 2, 3)
    assert.are.equal(2, ctx.start_line)
    assert.are.equal(3, ctx.end_line)
    assert.are.same({ "line 2", "line 3" }, ctx.lines)
  end)

  it("normalizes a reversed range", function()
    local ctx = context.from_range(bufnr, 3, 2)
    assert.are.equal(2, ctx.start_line)
    assert.are.equal(3, ctx.end_line)
    assert.are.same({ "line 2", "line 3" }, ctx.lines)
  end)
end)
