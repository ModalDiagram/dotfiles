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

map("n", "<space>ld", vim.lsp.buf.definition, { desc = "go to definition" })
map("n", "<space>lh", vim.lsp.buf.hover, {desc = "get info"})
map("n", "<space>lH", vim.lsp.buf.signature_help, {desc = "get signature"})
map("n", "<space>lr", vim.lsp.buf.rename, { desc = "varialbe rename" })
map("n", "<space>lf", vim.lsp.buf.references, { desc = "show references" })
map("n", "<space>lp", diagnostic.goto_prev, { desc = "previous diagnostic" })
map("n", "<space>ln", diagnostic.goto_next, { desc = "next diagnostic" })
map("n", "<space>lq", diagnostic.setqflist, { desc = "put diagnostic to qf" })
map("n", "<space>la", vim.lsp.buf.code_action, { desc = "LSP code action" })
map("n", "<space>wa", vim.lsp.buf.add_workspace_folder, { desc = "add workspace folder" })
map("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, { desc = "remove workspace folder" })
map("n", "<space>wl", function()
  inspect(vim.lsp.buf.list_workspace_folders())
end, { desc = "list workspace folder" })

 api.nvim_create_autocmd("CursorHold", {
  callback = function()
    local float_opts = {
      focusable = false,
      close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
      border = "rounded",
      source = "always", -- show source in diagnostic popup window
      prefix = " ",
    }

    if not vim.b.diagnostics_pos then
      vim.b.diagnostics_pos = { nil, nil }
    end

    local cursor_pos = api.nvim_win_get_cursor(0)
    if (cursor_pos[1] ~= vim.b.diagnostics_pos[1] or cursor_pos[2] ~= vim.b.diagnostics_pos[2])
        and #diagnostic.get() > 0
    then
      diagnostic.open_float(nil, float_opts)
    end

    vim.b.diagnostics_pos = cursor_pos
  end,
})



  api.nvim_create_autocmd("CursorMoved" , {
    group = gid,
    buffer = bufnr,
    callback = function ()
      lsp.buf.clear_references()
    end
  })

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
lsp.handlers["textDocument/hover"] = lsp.with(vim.lsp.handlers.hover, {
  border = "rounded",
})
