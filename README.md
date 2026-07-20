# context-yank.nvim

Yank the current file or a visual selection as a **structured Markdown block** to
your clipboard, ready to paste into an LLM such as Claude Code. No API keys, no
integrations — it just puts well-formatted context on the clipboard.

````
`lua/context-yank/format.lua` (L10-L20)

```lua
local function build_header(ctx)
  local header = "`" .. ctx.path .. "`"
  return header
end
```
````

## Features

- Yank the whole file or any visual range.
- Path shown relative to the Git root (falls back to the current working directory).
- Correct language fence from the buffer's `filetype`.
- Fence automatically widened when the content itself contains backticks.

## Requirements

- Neovim >= 0.9
- A working clipboard provider (see `:help clipboard`) for the default `+` register.

## Installation

### lazy.nvim

```lua
{
  "ymtdzzz/context-yank.nvim",
  cmd = { "ContextYank", "ContextYankFile" },
  opts = {},
}
```

### packer.nvim

```lua
use({
  "ymtdzzz/context-yank.nvim",
  config = function()
    require("context-yank").setup({})
  end,
})
```

## Usage

| Command             | Description                                           |
| ------------------- | ----------------------------------------------------- |
| `:ContextYank`      | Yank the whole file (no range) or the selected range. |
| `:'<,'>ContextYank` | Yank the visual selection with its line range.        |
| `:ContextYankFile`  | Always yank the whole file.                           |

Then paste with `"+p` (or `Cmd/Ctrl+v` outside Neovim).

### Suggested keymaps

```lua
vim.keymap.set("n", "<leader>cy", "<cmd>ContextYankFile<cr>", { desc = "Context yank: file" })
vim.keymap.set("x", "<leader>cy", ":ContextYank<cr>", { desc = "Context yank: selection" })
```

## Configuration

Defaults:

```lua
require("context-yank").setup({
  register = "+",       -- register to yank into (system clipboard)
  path_style = "auto",  -- "auto" (git root -> cwd) | "relative" (cwd) | "absolute"
  notify = true,        -- notify on successful yank
  trim_indent = false,  -- strip common leading indentation from a selection
})
```

## Development

```sh
make lint     # stylua --check . && selene .
make format   # stylua .
make test     # clones plenary.nvim into .tests/ and runs the busted specs
```

## License

MIT
