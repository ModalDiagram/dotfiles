local fn = vim.fn
local lsp = vim.lsp
local diagnostic = vim.diagnostic

-- Change diagnostic signs.
vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "✗",
      [vim.diagnostic.severity.WARN] = "!",
      [vim.diagnostic.severity.INFO] = "",
      [vim.diagnostic.severity.HINT] = "",
    },
  },
})

-- global config for diagnostic
diagnostic.config {
  underline = false,
  virtual_text = false,
  signs = true,
  severity_sort = true,
}

-- Change border of documentation hover window, See https://github.com/neovim/neovim/pull/13998.
  -- Disable Diagnostcs globally
  lsp.handlers["textDocument/hover"] = lsp.with(vim.lsp.handlers.hover, {
  border = "rounded",
})

vim.lsp.enable('rust_analyzer')
-- vim.lsp.enable(shellcheck'
vim.lsp.enable('bashls')
vim.lsp.enable('pylsp')
vim.lsp.enable('lua_ls')
vim.lsp.enable('r_language_server')
vim.lsp.enable('nil_ls')
vim.lsp.enable('texlab')
vim.lsp.enable('gopls')
vim.lsp.enable('clangd')
vim.lsp.enable('jsonls')
vim.lsp.enable('ts_ls')

