-- Git integration, see https://github.com/tpope/vim-fugitive
return {
  "tpope/vim-fugitive",
  keys = {
    { "<leader>gs", ":Git<CR>", desc = "Git status" },
    { "<leader>gd", ":Gdiffsplit<CR>", desc = "Git diff split" },
    { "<leader>gb", ":Git blame<CR>", desc = "Git blame" },
    { "<leader>gl", ":Git log<CR>", desc = "Git log" },
  },
  cmd = { "Git", "G", "Gdiffsplit", "Gread", "Gwrite", "GMove", "GDelete", "GBrowse" },
}
