if vim.g.loaded_context_yank then
  return
end
vim.g.loaded_context_yank = true

-- `:ContextYank` yanks the whole file when invoked without a range, or the
-- given range (e.g. from a visual selection) when one is supplied.
vim.api.nvim_create_user_command("ContextYank", function(opts)
  local cy = require("context-yank")
  if opts.range > 0 then
    cy.yank_range(opts.line1, opts.line2)
  else
    cy.yank_file()
  end
end, {
  range = true,
  desc = "Yank structured context (file or selected range) to the clipboard",
})

-- Explicit whole-file variant, handy for keymaps.
vim.api.nvim_create_user_command("ContextYankFile", function()
  require("context-yank").yank_file()
end, {
  desc = "Yank the whole file as structured context to the clipboard",
})
