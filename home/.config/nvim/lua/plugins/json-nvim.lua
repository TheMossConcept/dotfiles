-- JSON editing enhancements via jq and treesitter, see https://github.com/VPavliashvili/json-nvim
return {
  "VPavliashvili/json-nvim",
  ft = "json",
  keys = {
    -- Format
    { "<leader>pff", "<cmd>JsonFormatFile<cr>", desc = "JSON: Format file" },
    { "<leader>pft", "<cmd>JsonFormatToken<cr>", desc = "JSON: Format token under cursor" },
    { "<leader>pfs", "<cmd>JsonFormatSelection<cr>", mode = "v", desc = "JSON: Format selection" },
    -- Minify
    { "<leader>pmf", "<cmd>JsonMinifyFile<cr>", desc = "JSON: Minify file" },
    { "<leader>pmt", "<cmd>JsonMinifyToken<cr>", desc = "JSON: Minify token under cursor" },
    { "<leader>pms", "<cmd>JsonMinifySelection<cr>", mode = "v", desc = "JSON: Minify selection" },
    -- Escape / Unescape
    { "<leader>pef", "<cmd>JsonEscapeFile<cr>", desc = "JSON: Escape file" },
    { "<leader>puf", "<cmd>JsonUnescapeFile<cr>", desc = "JSON: Unescape file" },
    { "<leader>pes", "<cmd>JsonEscapeSelection<cr>", mode = "v", desc = "JSON: Escape selection" },
    { "<leader>pus", "<cmd>JsonUnescapeSelection<cr>", mode = "v", desc = "JSON: Unescape selection" },
    -- Key case conversion
    { "<leader>pkc", "<cmd>JsonKeysToCamelCase<cr>", desc = "JSON: Keys to camelCase" },
    { "<leader>pkp", "<cmd>JsonKeysToPascalCase<cr>", desc = "JSON: Keys to PascalCase" },
    { "<leader>pks", "<cmd>JsonKeysToSnakeCase<cr>", desc = "JSON: Keys to snake_case" },
  },
}
