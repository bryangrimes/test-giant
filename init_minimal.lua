vim.g._TEST = true
vim.g.testgiant_skip_plugin = true

vim.cmd("set rtp+=~/.local/share/nvim/lazy/plenary.nvim")
vim.cmd("set rtp+=~/.local/share/nvim/lazy/nvim-treesitter")
vim.cmd("set rtp+=~/.local/share/nvim/lazy/vim-test")
vim.cmd("set rtp+=/Users/bryan/dev/lua/testgiant")

require("testgiant").setup()
