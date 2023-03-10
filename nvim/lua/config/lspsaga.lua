require("lspsaga").setup({
  lightbulb = {
    enable = false,
  },
  symbol_in_winbar = {
    enable = true,
    separator = " ",
    ignore_patterns={},
    hide_keyword = true,
    show_file = true,
    folder_level = 2,
    respect_root = true,
    color_mode = true,
  },
  diagnostic = {
    on_insert=false,
  },
  outline = {
    keys = {
      jump = "<Enter>",
      expand_collapse = "-",
      quit = "q",
    },
  }
})

vim.keymap.set("n", "<space>lf", "<cmd>Lspsaga lsp_finder<cr>", { desc = "show references(saga)" })
vim.keymap.set("n", "<space>lg", "<cmd>Lspsaga goto_definition<cr>", { desc = "goto definition" })
vim.keymap.set("n", "<space>ld", "<cmd>Lspsaga show_buf_diagnostics<cr>", { desc = "show diagnostics" })
vim.keymap.set("n", "<space>lh", "<cmd>Lspsaga peek_definition<cr>", {desc = "peek variable"})
vim.keymap.set("n", "<space>lH", "<cmd>Lspsaga peek_type_definition<cr>", {desc = "peek class"})
vim.keymap.set("n", "<space>lt", "<cmd>Lspsaga hover_doc<cr>", {desc = "get type"})
vim.keymap.set("n", "<space>lr", "<cmd>Lspsaga rename<cr>", { desc = "variable rename" })
vim.keymap.set("n", "<space>ln", "<cmd>Lspsaga diagnostic_jump_next<cr>", { desc = "Next diagnostics"})
vim.keymap.set("n", "<space>lp", "<cmd>Lspsaga diagnostic_jump_previous<cr>", { desc = "Previous diagnostics"})
vim.keymap.set("n", "<space>lF", vim.lsp.buf.references, { desc = "show references (lsp)" })
vim.keymap.set("n", "<space>la", "<cmd>Lspsaga code_action<cr>", { desc = "LSP code action" })
vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, { desc = "add workspace folder" })
vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, { desc = "remove workspace folder" })
vim.keymap.set("n", "<space>t", "<cmd>Lspsaga outline<cr>", { desc = "vedi classi e metodi" })
vim.keymap.set("n", "<space>wl", function()
  inspect(vim.lsp.buf.list_workspace_folders())
end, { desc = "list workspace folder" })
