local fn = vim.fn

-- local diff = function()
--   local git_status = vim.b.gitsigns_status_dict
--   if git_status == nil then
--     return
--   end

--   local modify_num = git_status.changed
--   local remove_num = git_status.removed
--   local add_num = git_status.added

--   local info = { added = add_num, modified = modify_num, removed = remove_num }
--   -- vim.pretty_print(info)
--   return info
-- end

require("lualine").setup {
  options = {
    icons_enabled = true,
    theme = "rose-pine",
    -- component_separators = { left = "", right = "" },
    -- section_separators = { left = "", right = "" },
    section_separators = "",
    component_separators = "",
    disabled_filetypes = {},
    always_divide_middle = true,
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = {
      "branch",
    },
    lualine_c = {
      "filename",
    },
    lualine_x = {
      "encoding",
      "filetype",
    },
    lualine_y = { "progress" },
    lualine_z = {
      "location",
      -- {
      --   "diagnostics",
      --   sources = { "nvim_diagnostic" },
      -- },
    },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { "filename" },
    lualine_x = { "location" },
    lualine_y = {},
    lualine_z = {},
  },
  tabline = {},
  extensions = { "nvim-tree" },
}
