local path = require("context-yank.path")

describe("path.resolve", function()
  local tmp

  before_each(function()
    tmp = vim.fn.tempname()
    vim.fn.mkdir(tmp .. "/repo/lua", "p")
    vim.fn.mkdir(tmp .. "/repo/.git", "p")
    vim.fn.writefile({ "" }, tmp .. "/repo/lua/foo.lua")
  end)

  after_each(function()
    vim.fn.delete(tmp, "rf")
  end)

  it("resolves git root relative paths in auto mode", function()
    local file = tmp .. "/repo/lua/foo.lua"
    assert.are.equal("lua/foo.lua", path.resolve(file, "auto"))
  end)

  it("falls back to cwd relative when outside a git repo", function()
    -- A file with no .git ancestor: use a temp file directly under tempname.
    local outside = vim.fn.tempname()
    vim.fn.writefile({ "" }, outside)
    -- In auto mode this should not error and should return a string.
    local resolved = path.resolve(outside, "auto")
    assert.is_string(resolved)
    vim.fn.delete(outside)
  end)

  it("returns an absolute path in absolute mode", function()
    local file = tmp .. "/repo/lua/foo.lua"
    local resolved = path.resolve(file, "absolute")
    assert.are.equal(vim.fs.normalize(file), resolved)
  end)

  it("finds the git root for a file inside a repo", function()
    local file = tmp .. "/repo/lua/foo.lua"
    assert.are.equal(vim.fs.normalize(tmp .. "/repo"), vim.fs.normalize(path.git_root(file)))
  end)

  it("returns a placeholder for an empty buffer name", function()
    assert.are.equal("[No Name]", path.resolve("", "auto"))
  end)
end)
