return {
  "mason-org/mason-lspconfig.nvim",
  opts = {
    ensure_installed = { "lua_ls", "ts_ls" }
  },
  dependencies = {
    { "mason-org/mason.nvim",
      opts = {
        ui = {
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
          }
        }
      },
      config = function(_, opts)
        require("mason").setup(opts)

        local group = vim.api.nvim_create_augroup("FormatOnSave", { clear = true })
        vim.api.nvim_create_autocmd("BufWritePost", {
          group = group,
          pattern = { "*.ts", "*.tsx", "*.js", "*.jsx" },
          callback = function()
            local file = vim.fn.expand("%:p")
            vim.fn.system({ "prettier", "--write", file })
            vim.cmd("edit")
          end,
        })
      end,
    },
    { "neovim/nvim-lspconfig" },
  },
}
