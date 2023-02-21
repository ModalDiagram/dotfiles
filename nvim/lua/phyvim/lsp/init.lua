local M = {}

M.load = function()
  local status_ok, _ = pcall(require, "lspconfig")
  if not status_ok then
    return
  end

  require "phyvim.lsp.lsp-installer"
  require("phyvim.lsp.handlers").setup()
  require("phyvim.lsp.null-ls").setup()
  require'lspconfig'.pyright.setup{}
  require'lspconfig'.ccls.setup{}
  require'lspconfig'.jdtls.setup{}
end

return M
