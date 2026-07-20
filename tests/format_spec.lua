local format = require("context-yank.format")

describe("format.to_markdown", function()
  it("renders a whole-file context without a line range", function()
    local ctx = {
      path = "lua/foo/bar.lua",
      lang = "lua",
      start_line = nil,
      end_line = nil,
      lines = { "local x = 1", "return x" },
    }
    local expected = table.concat({
      "`lua/foo/bar.lua`",
      "",
      "```lua",
      "local x = 1",
      "return x",
      "```",
    }, "\n")
    assert.are.equal(expected, format.to_markdown(ctx))
  end)

  it("renders a multi-line range header", function()
    local ctx = {
      path = "a.lua",
      lang = "lua",
      start_line = 10,
      end_line = 20,
      lines = { "x" },
    }
    local header = format.to_markdown(ctx):match("^[^\n]*")
    assert.are.equal("`a.lua` (L10-L20)", header)
  end)

  it("renders a single-line range header", function()
    local ctx = {
      path = "a.lua",
      lang = "lua",
      start_line = 7,
      end_line = 7,
      lines = { "x" },
    }
    local header = format.to_markdown(ctx):match("^[^\n]*")
    assert.are.equal("`a.lua` (L7)", header)
  end)

  it("omits the language when filetype is empty", function()
    local ctx = { path = "notes.txt", lang = "", lines = { "hello" } }
    local out = format.to_markdown(ctx)
    assert.is_truthy(out:find("\n```\nhello\n```", 1, true))
  end)

  it("expands the fence when the content contains backticks", function()
    local ctx = {
      path = "readme.md",
      lang = "markdown",
      lines = { "```lua", "print(1)", "```" },
    }
    local out = format.to_markdown(ctx)
    -- Outer fence must be longer than the inner triple backticks.
    assert.is_truthy(out:find("````markdown", 1, true))
    assert.is_truthy(out:find("\n````$"))
  end)

  it("trims common indentation when requested", function()
    local ctx = {
      path = "a.lua",
      lang = "lua",
      lines = { "    if x then", "      return 1", "    end" },
    }
    local out = format.to_markdown(ctx, { trim_indent = true })
    assert.is_truthy(out:find("\nif x then\n", 1, true))
    assert.is_truthy(out:find("\n  return 1\n", 1, true))
  end)
end)
