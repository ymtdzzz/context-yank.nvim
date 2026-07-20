-- Minimal init used to run the plenary busted tests in headless Neovim.
-- Expects plenary.nvim to be available at ./.tests/plenary.nvim (see CI /
-- the `test` make target) and adds this plugin itself to the runtimepath.

local root = vim.fn.fnamemodify(vim.fn.getcwd(), ":p")
local plenary = root .. ".tests/plenary.nvim"

vim.opt.runtimepath:append(root)
vim.opt.runtimepath:append(plenary)

vim.cmd("runtime plugin/plenary.vim")
require("plenary.busted")
