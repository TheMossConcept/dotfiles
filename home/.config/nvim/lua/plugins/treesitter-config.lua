return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  version = false,
  build = ":TSUpdate",
  lazy = false,
  config = function()
    require("nvim-treesitter").setup()

    -- Install parsers automatically
    local ensure_installed = {
      "bash",
      "typescript",
      "tsx",
      "diff",
      "dockerfile",
      "html",
      "json",
      "http",
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
    }

    local installed = require("nvim-treesitter").get_installed()
    local installed_set = {}
    for _, lang in ipairs(installed) do
      installed_set[lang] = true
    end
    local to_install = {}
    for _, lang in ipairs(ensure_installed) do
      if not installed_set[lang] then
        table.insert(to_install, lang)
      end
    end
    if #to_install > 0 then
      require("nvim-treesitter").install(to_install)
    end

    -- Enable treesitter highlighting and indentation for all buffers
    vim.api.nvim_create_autocmd("FileType", {
      callback = function()
        pcall(vim.treesitter.start)
        vim.bo.indentexpr = "v:lua.require('nvim-treesitter').indentexpr()"
      end,
    })

    -- Earthy, calming TreeSitter highlight overrides
    -- Palette: warm browns, muted greens, soft clay, sage, stone, ochre
    local hi = function(group, settings)
      vim.api.nvim_set_hl(0, group, settings)
    end

    -- Keywords & control flow — clay/terracotta
    hi("@keyword",              { fg = "#b07856" })
    hi("@keyword.return",       { fg = "#b07856", bold = true })
    hi("@keyword.export",       { fg = "#b07856" })
    hi("@keyword.import",       { fg = "#b07856" })
    hi("@keyword.operator",     { fg = "#b07856" })
    hi("@conditional",          { fg = "#b07856" })
    hi("@repeat",               { fg = "#b07856" })
    hi("@exception",            { fg = "#b07856" })

    -- Functions — sage green
    hi("@function",             { fg = "#8aad7e" })
    hi("@function.call",        { fg = "#8aad7e" })
    hi("@function.method",      { fg = "#8aad7e" })
    hi("@function.method.call", { fg = "#8aad7e" })
    hi("@function.builtin",     { fg = "#8aad7e", italic = true })

    -- Types & interfaces — warm ochre/sand
    hi("@type",                 { fg = "#d4a35a" })
    hi("@type.builtin",         { fg = "#d4a35a", italic = true })
    hi("@type.definition",      { fg = "#d4a35a", bold = true })
    hi("@type.qualifier",       { fg = "#d4a35a" })

    -- Variables — warm stone/light tan
    hi("@variable",             { fg = "#c4b097" })
    hi("@variable.builtin",     { fg = "#c4b097", italic = true })
    hi("@variable.parameter",   { fg = "#bfae94" })
    hi("@variable.member",      { fg = "#c9b89d" })

    -- Constants & numbers — muted copper
    hi("@constant",             { fg = "#cc9966" })
    hi("@constant.builtin",     { fg = "#cc9966", italic = true })
    hi("@boolean",              { fg = "#cc9966", bold = true })
    hi("@number",               { fg = "#cc9966" })
    hi("@number.float",         { fg = "#cc9966" })

    -- Strings — soft moss green
    hi("@string",               { fg = "#7d9970" })
    hi("@string.escape",        { fg = "#6b8760", bold = true })
    hi("@string.regex",         { fg = "#6b8760" })
    hi("@string.special",       { fg = "#6b8760" })

    -- Operators & punctuation — muted stone grey
    hi("@operator",             { fg = "#9a9085" })
    hi("@punctuation.bracket",  { fg = "#9a9085" })
    hi("@punctuation.delimiter",{ fg = "#9a9085" })
    hi("@punctuation.special",  { fg = "#9a9085" })

    -- Properties — dusty tan
    hi("@property",             { fg = "#a8917a" })

    -- Comments — faded olive
    hi("@comment",              { fg = "#6b7558", italic = true })
    hi("@comment.documentation",{ fg = "#7a8567", italic = true })

    -- JSX/TSX tags — warm sienna
    hi("@tag",                  { fg = "#b08060" })
    hi("@tag.builtin",          { fg = "#b08060" })
    hi("@tag.delimiter",        { fg = "#8a7060" })
    hi("@tag.attribute",        { fg = "#a09060" })

    -- Constructors & modules — warm ochre (matches types)
    hi("@constructor",          { fg = "#d4a35a" })
    hi("@module",               { fg = "#c4a060" })

    -- Labels & includes
    hi("@label",                { fg = "#b07856" })
    hi("@include",              { fg = "#b07856" })
  end
}
