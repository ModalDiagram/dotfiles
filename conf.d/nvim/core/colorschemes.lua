require("NeoSolarized").setup {
  transparent = false,
}
vim.cmd[[colorscheme NeoSolarized]]
vim.api.nvim_set_hl(0, 'LeapLabelPrimary', { fg = 'white', bg = "black", bold = true })
