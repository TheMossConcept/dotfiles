return {
  "nvim-treesitter/nvim-treesitter",
  version = false,
  build = ":TSUpdate",
  lazy = false,
  opts = {
    -- LazyVim config for treesitter
    indent = { enable = true },
    highlight = { enable = true },
    folds = { enable = true },
    lazy = false,
    ensure_installed = {
      "bash",
      "typescript",
      "tsx",
      "diff",
      "dockerfile",
      "html",
      "json",
      "jsonc",
      "lua",
      "luadoc",
      "markdown",
      "markdown_inline",
      "python",
      "regex",
      "vim",
      "vimdoc",
      "xml",
      "yaml",
    },
  },
  config = function(_, opts)
    require("nvim-treesitter.configs").setup(opts)
  end
}

