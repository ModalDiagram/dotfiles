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

require("lspconfig").rust_analyzer.setup{}
-- require("lspconfig").shellcheck.setup{}
require("lspconfig").bashls.setup{}
require("lspconfig").pylsp.setup{}
require("lspconfig").lua_ls.setup{}
require("lspconfig").r_language_server.setup{}
require("lspconfig").nil_ls.setup{}
require("lspconfig").texlab.setup{}
require("lspconfig").gopls.setup{}
require("lspconfig").clangd.setup{}
require("lspconfig").jsonls.setup{}
require("lspconfig").ts_ls.setup{}

