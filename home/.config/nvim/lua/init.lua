require("config.lazy")

-- Use cb-copy/cb-paste for clipboard so tmux and neovim share the same clipboard tool
vim.g.clipboard = {
  name = 'cb-clipboard',
  copy = {
    ['+'] = 'cb-copy',
    ['*'] = 'cb-copy',
  },
  paste = {
    ['+'] = 'cb-paste',
    ['*'] = 'cb-paste',
  },
  cache_enabled = 0,
}

-- To avoid vim resizing panes on maximising/minimising in tmux
vim.o.equalalways = false

-- Prevent Neo-tree (and other sidebars) from going blank when scrolling in adjacent splits
vim.o.splitkeep = "screen"

-- Workaround for diagnostics disappearing in insert mode causing the whole UI to continously jump around 
vim.diagnostic.config({
    update_in_insert = true,
    --[[
    virtual_text = true,
    signs = true,
    underline = true,
    severity_sort = false,
    float = true,
    ]]
  })
