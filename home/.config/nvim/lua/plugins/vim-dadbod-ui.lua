-- Database UI, see https://github.com/kristijanhusak/vim-dadbod-ui
return {
  "kristijanhusak/vim-dadbod-ui",
  dependencies = {
    { "tpope/vim-dadbod", lazy = true },
    { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
  },
  keys = {
    { "<leader>db", ":DBUIToggle<CR>", desc = "Toggle DBUI" },
    { "<leader>da", ":DBUIAddConnection<CR>", desc = "Add DB connection" },
    { "<leader>df", ":DBUIFindBuffer<CR>", desc = "Find DB buffer" },
  },
  cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
  init = function()
    vim.g.db_ui_use_nerd_fonts = 1
  end,
}
