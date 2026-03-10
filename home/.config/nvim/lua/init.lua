require("config.lazy")

-- To avoid vim resizing panes on maximising/minimising in tmux
vim.o.equalalways = false

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
