local fn = vim.fn
local lsp = vim.lsp
local diagnostic = vim.diagnostic

-- Change diagnostic signs.
fn.sign_define("DiagnosticSignError", { text = "✗", texthl = "DiagnosticSignError" })
fn.sign_define("DiagnosticSignWarn", { text = "!", texthl = "DiagnosticSignWarn" })
fn.sign_define("DiagnosticSignInformation", { text = "", texthl = "DiagnosticSignInfo" })
fn.sign_define("DiagnosticSignHint", { text = "", texthl = "DiagnosticSignHint" })

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
