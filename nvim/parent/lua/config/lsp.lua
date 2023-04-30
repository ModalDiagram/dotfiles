local fn = vim.fn
local api = vim.api
local keymap = vim.keymap
local lsp = vim.lsp
local diagnostic = vim.diagnostic

-- Mappings.
local map = function(mode, l, r, opts)
  opts = opts or {}
  opts.silent = true
  keymap.set(mode, l, r, opts)
end



if vim.g.logging_level == "debug" then
  local msg = string.format("Language server %s started!", client.name)
  vim.notify(msg, vim.log.levels.DEBUG, { title = "Nvim-config" })
end


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

-- lsp.handlers["textDocument/publishDiagnostics"] = lsp.with(lsp.diagnostic.on_publish_diagnostics, {
--   underline = false,
--   virtual_text = false,
--   signs = true,
--   update_in_insert = false,
-- })

-- Change border of documentation hover window, See https://github.com/neovim/neovim/pull/13998.
  -- Disable Diagnostcs globally
  lsp.handlers["textDocument/hover"] = lsp.with(vim.lsp.handlers.hover, {
  border = "rounded",
})
