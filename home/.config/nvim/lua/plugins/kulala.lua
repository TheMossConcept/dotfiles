return {
  "mistweaverco/kulala.nvim",
  keys = {
    { "<leader>Rs", desc = "Send request" },
    { "<leader>Ra", desc = "Send all requests" },
    { "<leader>Rb", desc = "Open scratchpad" },
    { "<leader>Ry", function() require("kulala").copy() end, desc = "Copy as curl" },
  },
  ft = { "http", "rest" },
  opts = {
    -- your configuration comes here
    global_keymaps = true,
    global_keymaps_prefix = "<leader>R",
    kulala_keymaps_prefix = "",
  },
  config = function(_, opts)
    require("kulala").setup(opts)
    vim.filetype.add({
      extension = {
        ['http'] = 'http',
      },
    })
  end
}
